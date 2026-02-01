import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/domain/entry.dart';

class EntryDetailPage extends ConsumerStatefulWidget {
  const EntryDetailPage({super.key, required this.entryId});

  final String entryId;

  @override
  ConsumerState<EntryDetailPage> createState() => _EntryDetailPageState();
}

class _EntryDetailPageState extends ConsumerState<EntryDetailPage> {
  Future<Entry?>? _future;

  @override
  void initState() {
    super.initState();
    _reload();
  }

  void _reload() {
    final repo = ref.read(entryRepositoryProvider);
    _future = repo.getById(widget.entryId);
  }

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(entryRepositoryProvider);
    final df = DateFormat('EEE, MMM d • h:mm a');

    return FutureBuilder<Entry?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        final entry = snap.data;
        if (entry == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Entry not found')),
          );
        }

        final title = entry.title.trim().isEmpty ? 'Untitled' : entry.title.trim();
        final body = entry.body.trim().isEmpty ? '(empty)' : entry.body.trim();

        final moodLabel =
            entry.mood == null ? null : ['Low', 'OK', 'High'][entry.mood!.clamp(0, 2)];

        return Scaffold(
          appBar: AppBar(
            title: const Text('Entry'),
            actions: [
              IconButton(
                tooltip: entry.pinned ? 'Unpin' : 'Pin',
                onPressed: () async {
                  await repo.save(
                    entry.copyWith(
                      pinned: !entry.pinned,
                      updatedAt: DateTime.now(),
                    ),
                  );
                  setState(_reload);
                },
                icon: Icon(entry.pinned ? Icons.push_pin : Icons.push_pin_outlined),
              ),
              IconButton(
                tooltip: 'Edit',
                onPressed: () => context.go('/entry/${entry.id}/edit'),
                icon: const Icon(Icons.edit),
              ),
              IconButton(
                tooltip: 'Delete',
                onPressed: () async {
                  final deleted = entry;
                  await repo.delete(entry.id);
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Entry deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await repo.save(deleted);
                        },
                      ),
                    ),
                  );

                  context.pop();
                },
                icon: const Icon(Icons.delete_outline),
              ),
            ],
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Text(
                      df.format(entry.updatedAt),
                      style: Theme.of(context)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(context).hintColor),
                    ),
                    if (moodLabel != null) ...[
                      const SizedBox(width: 12),
                      Text(
                        'Mood: $moodLabel',
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Theme.of(context).hintColor),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 12),
                if (entry.tags.isNotEmpty) ...[
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final t in entry.tags) Chip(label: Text(t)),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(body, style: Theme.of(context).textTheme.bodyLarge),
                        if (entry.tasks.isNotEmpty) ...[
                          const SizedBox(height: 16),
                          Text('Tasks', style: Theme.of(context).textTheme.titleMedium),
                          const SizedBox(height: 8),
                          for (final task in entry.tasks)
                            Row(
                              children: [
                                Icon(
                                  task.done
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  size: 18,
                                  color: task.done
                                      ? Colors.teal
                                      : Theme.of(context).hintColor,
                                ),
                                const SizedBox(width: 8),
                                Expanded(child: Text(task.text)),
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
