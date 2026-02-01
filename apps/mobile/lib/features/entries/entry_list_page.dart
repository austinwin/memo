import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/domain/entry.dart';

class EntryListPage extends ConsumerWidget {
  const EntryListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(entryRepositoryProvider);
    final df = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(title: const Text('Entries')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/new'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Entry>>(
        stream: repo.watchAll(),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snap.data!;
          if (entries.isEmpty) {
            return const Center(
              child: Text('No entries yet. Tap + to write your first one.'),
            );
          }

          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final e = entries[index];
              final title = e.title.trim().isEmpty ? 'Untitled' : e.title.trim();
              final subtitle = df.format(e.updatedAt);

              return ListTile(
                title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(subtitle),
                onTap: () => context.go('/entry/${e.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
