import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/domain/entry.dart';
import 'package:uuid/uuid.dart';

class EntryEditorPage extends ConsumerStatefulWidget {
  const EntryEditorPage({super.key, required this.entryId, this.dayKeyParam});

  final String? entryId;
  final String? dayKeyParam;

  @override
  ConsumerState<EntryEditorPage> createState() => _EntryEditorPageState();
}

class _EntryEditorPageState extends ConsumerState<EntryEditorPage> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  bool _loading = true;
  Entry? _existing;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(entryRepositoryProvider);

    if (widget.entryId != null) {
      _existing = await repo.getById(widget.entryId!);
      _titleController.text = _existing?.title ?? '';
      _bodyController.text = _existing?.body ?? '';
    }

    setState(() => _loading = false);
  }

  DateTime _createdAtForNewEntry(DateTime now) {
    final k = widget.dayKeyParam;
    if (k == null || k.isEmpty) return now;

    final parts = k.split('-');
    if (parts.length != 3) return now;

    // Keep time-of-day as now, but lock date to the selected day.
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
      now.hour,
      now.minute,
      now.second,
      now.millisecond,
      now.microsecond,
    );
  }

  Future<void> _save() async {
    final repo = ref.read(entryRepositoryProvider);
    final now = DateTime.now();

    final title = _titleController.text;
    final body = _bodyController.text;

    final entry = _existing == null
        ? Entry(
            id: const Uuid().v7(),
            title: title,
            body: body,
            createdAt: _createdAtForNewEntry(now),
            updatedAt: now,
          )
        : _existing!.copyWith(title: title, body: body, updatedAt: now);

    await repo.save(entry);

    if (!mounted) return;
    context.go('/entry/${entry.id}');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.entryId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New Entry' : 'Edit Entry'),
        actions: [
          TextButton(
            onPressed: _loading ? null : _save,
            child: const Text('Save'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: TextField(
                      controller: _bodyController,
                      keyboardType: TextInputType.multiline,
                      maxLines: null,
                      expands: true,
                      decoration: const InputDecoration(
                        hintText: 'Write…',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
