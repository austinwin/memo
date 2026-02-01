import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/domain/entry.dart';

class EntryListPage extends ConsumerStatefulWidget {
  const EntryListPage({super.key});

  @override
  ConsumerState<EntryListPage> createState() => _EntryListPageState();
}

class _EntryListPageState extends ConsumerState<EntryListPage> {
  bool _searching = false;
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final repo = ref.watch(entryRepositoryProvider);
    final df = DateFormat('MMM d, yyyy');

    return Scaffold(
      appBar: AppBar(
        title: _searching
            ? TextField(
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: 'Search…',
                  border: InputBorder.none,
                ),
                onChanged: (v) => setState(() => _query = v),
              )
            : const Text('Entries'),
        actions: [
          IconButton(
            tooltip: _searching ? 'Close search' : 'Search',
            onPressed: () {
              setState(() {
                _searching = !_searching;
                if (!_searching) _query = '';
              });
            },
            icon: Icon(_searching ? Icons.close : Icons.search),
          ),
          IconButton(
            tooltip: 'Calendar',
            onPressed: () => context.go('/calendar'),
            icon: const Icon(Icons.calendar_month),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/new'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Entry>>(
        stream: repo.watchAll(query: _query),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snap.data!;
          if (entries.isEmpty) {
            return const Center(
              child: Text('No entries yet — write one'),
            );
          }

          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final e = entries[index];
              final title = e.title.trim().isEmpty ? 'Untitled' : e.title.trim();
              final subtitle = df.format(e.updatedAt);

              return Dismissible(
                key: ValueKey(e.id),
                background: Container(
                  color: Colors.red.withValues(alpha: 0.15),
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: const Icon(Icons.delete_outline, color: Colors.red),
                ),
                direction: DismissDirection.endToStart,
                onDismissed: (_) async {
                  await repo.delete(e.id);
                  if (!context.mounted) return;

                  ScaffoldMessenger.of(context).clearSnackBars();
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: const Text('Entry deleted'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () async {
                          await repo.save(e);
                        },
                      ),
                    ),
                  );
                },
                child: ListTile(
                  leading: e.pinned
                      ? const Icon(Icons.push_pin, size: 18)
                      : null,
                  title: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(subtitle),
                  trailing: e.mood == null
                      ? null
                      : Text(
                          ['Low', 'OK', 'High'][e.mood!.clamp(0, 2)],
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: Theme.of(context).hintColor),
                        ),
                  onTap: () => context.go('/entry/${e.id}'),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
