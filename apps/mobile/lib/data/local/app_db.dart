import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

@DataClassName('EntryRow')
class Entries extends Table {
  TextColumn get id => text()();

  /// Local-day key (yyyy-MM-dd) for fast calendar + day browsing.
  TextColumn get dayKey => text()();

  TextColumn get title => text().withDefault(const Constant(''))();
  TextColumn get body => text().withDefault(const Constant(''))();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(tables: [Entries])
class AppDb extends _$AppDb {
  AppDb() : super(_openConnection());

  /// Test-only / override constructor.
  AppDb.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

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
        },
      );

  // Queries

  Stream<List<EntryRow>> watchEntries() {
    return (select(entries)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
  }

  Stream<List<EntryRow>> watchEntriesForDayKey(String key) {
    return (select(entries)
          ..where((t) => t.dayKey.equals(key))
          ..orderBy([(t) => OrderingTerm.desc(t.updatedAt)]))
        .watch();
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

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'app.db'));
    return NativeDatabase.createInBackground(file);
  });
}
