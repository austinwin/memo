import 'package:drift/drift.dart';

import 'connection/connection.dart';

part 'app_db.g.dart';

@DataClassName('EntryRow')
class Entries extends Table {
  TextColumn get id => text()();

  /// Local-day key (yyyy-MM-dd) for fast calendar + day browsing.
  TextColumn get dayKey => text()();

  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();

  // Parity columns
  IntColumn get mood => integer().nullable()();
  BoolColumn get pinned => boolean().withDefault(const Constant(false))();
  TextColumn get tagsJson => text().withDefault(const Constant('[]'))();
  TextColumn get tasksJson => text().withDefault(const Constant('[]'))();

  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Entries])
class AppDb extends _$AppDb {
  AppDb() : super(openConnection());

  /// Test-only / override constructor.
  AppDb.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX IF NOT EXISTS entries_day_key_idx ON entries(day_key)',
          );
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.addColumn(entries, entries.dayKey);
            await customStatement(
              'CREATE INDEX IF NOT EXISTS entries_day_key_idx ON entries(day_key)',
            );
          }
          if (from < 3) {
            await m.addColumn(entries, entries.mood);
            await m.addColumn(entries, entries.pinned);
            await m.addColumn(entries, entries.tagsJson);
            await m.addColumn(entries, entries.tasksJson);
          }
        },
      );

  // Queries

  Stream<List<EntryRow>> watchEntries({String query = ''}) {
    final q = query.trim();

    final sel = select(entries);
    if (q.isNotEmpty) {
      final like = '%$q%';
      sel.where(
        (t) => t.title.like(like) | t.body.like(like),
      );
    }

    sel.orderBy([
      (t) => OrderingTerm.desc(t.pinned),
      (t) => OrderingTerm.desc(t.updatedAt),
    ]);

    return sel.watch();
  }

  Stream<List<EntryRow>> watchEntriesForDayKey(String key, {String query = ''}) {
    final q = query.trim();

    final sel = select(entries)..where((t) => t.dayKey.equals(key));
    if (q.isNotEmpty) {
      final like = '%$q%';
      sel.where((t) => t.title.like(like) | t.body.like(like));
    }

    sel.orderBy([
      (t) => OrderingTerm.desc(t.pinned),
      (t) => OrderingTerm.desc(t.updatedAt),
    ]);

    return sel.watch();
  }

  Stream<Map<String, int>> watchDayCountsForPrefix(String prefix) {
    // prefix = yyyy-MM (month)
    final q = customSelect(
      'SELECT day_key as dayKey, COUNT(*) as cnt FROM entries '
      'WHERE day_key LIKE ? GROUP BY day_key',
      variables: [Variable<String>('$prefix%')],
      readsFrom: {entries},
    );

    return q.watch().map((rows) {
      final map = <String, int>{};
      for (final r in rows) {
        map[r.read<String>('dayKey')] = r.read<int>('cnt');
      }
      return map;
    });
  }

  Future<EntryRow?> getEntry(String id) {
    return (select(entries)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<void> upsertEntry(EntriesCompanion data) {
    return into(entries).insertOnConflictUpdate(data);
  }

  Future<int> deleteEntryById(String id) {
    return (delete(entries)..where((t) => t.id.equals(id))).go();
  }
}
