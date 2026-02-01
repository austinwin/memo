import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile/app/providers.dart';
import 'package:mobile/domain/entry.dart';
// (unused)

class DayEntriesPage extends ConsumerWidget {
  const DayEntriesPage({super.key, required this.dayKeyValue});

  final String dayKeyValue;

  DateTime _parseDayKey(String k) {
    // yyyy-MM-dd
    final parts = k.split('-');
    if (parts.length != 3) return DateTime.now();
    return DateTime(
      int.parse(parts[0]),
      int.parse(parts[1]),
      int.parse(parts[2]),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final repo = ref.watch(entryRepositoryProvider);
    final day = _parseDayKey(dayKeyValue);
    final title = DateFormat('EEE, MMM d').format(day);

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/new?day=$dayKeyValue'),
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<List<Entry>>(
        stream: repo.watchForDay(day),
        builder: (context, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snap.data!;
          if (entries.isEmpty) {
            return Center(
              child: Text(
                'No entries for this day',
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium
                    ?.copyWith(color: Theme.of(context).hintColor),
              ),
            );
          }

          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final e = entries[index];
              final t = e.title.trim().isEmpty ? '(Untitled)' : e.title.trim();

              return ListTile(
                title: Text(t, maxLines: 1, overflow: TextOverflow.ellipsis),
                subtitle: Text(DateFormat('h:mm a').format(e.updatedAt)),
                onTap: () => context.go('/entry/${e.id}/edit'),
              );
            },
          );
        },
      ),
    );
  }
}
