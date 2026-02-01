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
  final _tagController = TextEditingController();
  final _taskController = TextEditingController();

  bool _loading = true;
  Entry? _existing;

  int? _mood;
  bool _pinned = false;
  List<String> _tags = <String>[];
  List<TaskItem> _tasks = <TaskItem>[];

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
      _mood = _existing?.mood;
      _pinned = _existing?.pinned ?? false;
      _tags = List<String>.from(_existing?.tags ?? const <String>[]);
      _tasks = List<TaskItem>.from(_existing?.tasks ?? const <TaskItem>[]);
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
            mood: _mood,
            pinned: _pinned,
            tags: _tags,
            tasks: _tasks,
          )
        : _existing!.copyWith(
            title: title,
            body: body,
            updatedAt: now,
            mood: _mood,
            pinned: _pinned,
            tags: _tags,
            tasks: _tasks,
          );

    await repo.save(entry);

    if (!mounted) return;
    context.go('/entry/${entry.id}');
  }

  void _addTag() {
    final raw = _tagController.text.trim();
    if (raw.isEmpty) return;

    final parts = raw
        .split(RegExp(r'[ ,]+'))
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();

    setState(() {
      for (final t in parts) {
        if (!_tags.contains(t)) _tags.add(t);
      }
      _tagController.clear();
    });
  }

  void _addTask() {
    final text = _taskController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _tasks = [..._tasks, TaskItem(text: text, done: false)];
      _taskController.clear();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    _tagController.dispose();
    _taskController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.entryId == null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'New Entry' : 'Edit Entry'),
        actions: [
          IconButton(
            tooltip: _pinned ? 'Unpin' : 'Pin',
            onPressed: _loading ? null : () => setState(() => _pinned = !_pinned),
            icon: Icon(_pinned ? Icons.push_pin : Icons.push_pin_outlined),
          ),
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
              child: ListView(
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
                  TextField(
                    controller: _bodyController,
                    keyboardType: TextInputType.multiline,
                    maxLines: 10,
                    minLines: 6,
                    decoration: const InputDecoration(
                      hintText: 'Write…',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Mood (3-level)
                  Text('Mood', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SegmentedButton<int>(
                    segments: const [
                      ButtonSegment(value: 0, label: Text('Low')),
                      ButtonSegment(value: 1, label: Text('OK')),
                      ButtonSegment(value: 2, label: Text('High')),
                    ],
                    selected: _mood == null ? <int>{} : <int>{_mood!},
                    emptySelectionAllowed: true,
                    onSelectionChanged: (s) {
                      setState(() {
                        _mood = s.isEmpty ? null : s.first;
                      });
                    },
                  ),
                  const SizedBox(height: 16),

                  // Tags
                  Text('Tags', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in _tags)
                        InputChip(
                          label: Text(t),
                          onDeleted: () => setState(() => _tags.remove(t)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _tagController,
                          decoration: const InputDecoration(
                            hintText: 'Add tag',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addTag(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _addTag,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tasks
                  Text('Tasks', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  for (final task in _tasks)
                    CheckboxListTile(
                      value: task.done,
                      title: Text(task.text),
                      controlAffinity: ListTileControlAffinity.leading,
                      secondary: IconButton(
                        tooltip: 'Remove',
                        onPressed: () {
                          setState(() {
                            _tasks = _tasks.where((t) => t != task).toList();
                          });
                        },
                        icon: const Icon(Icons.close),
                      ),
                      onChanged: (v) {
                        setState(() {
                          _tasks = _tasks
                              .map(
                                (t) => t == task
                                    ? t.copyWith(done: v ?? false)
                                    : t,
                              )
                              .toList();
                        });
                      },
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _taskController,
                          decoration: const InputDecoration(
                            hintText: 'Add task',
                            border: OutlineInputBorder(),
                          ),
                          onSubmitted: (_) => _addTask(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FilledButton(
                        onPressed: _addTask,
                        child: const Text('Add'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
    );
  }
}
