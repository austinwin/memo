import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_db.g.dart';

@DataClassName('EntryRow')
class Entries extends Table {
  TextColumn get id => text()();
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

  @override
  int get schemaVersion => 1;

  // Queries

  Stream<List<EntryRow>> watchEntries() {
    return (select(entries)..orderBy([(t) => OrderingTerm.desc(t.updatedAt)])).watch();
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
