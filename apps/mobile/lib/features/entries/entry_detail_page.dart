import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/providers.dart';

class EntryDetailPage extends ConsumerWidget {
  const EntryDetailPage({super.key, required this.entryId});

  final String entryId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(entryRepositoryProvider);
    final df = DateFormat('EEE, MMM d • h:mm a');

    return FutureBuilder(
      future: repo.getById(entryId),
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

        return Scaffold(
          appBar: AppBar(
            title: const Text('Entry'),
            actions: [
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
                Text(
                  df.format(entry.updatedAt),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Theme.of(context).hintColor),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(body, style: Theme.of(context).textTheme.bodyLarge),
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
