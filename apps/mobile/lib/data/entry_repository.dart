import 'package:drift/drift.dart';
import 'package:mobile/data/local/app_db.dart';
import 'package:mobile/domain/entry.dart';

class EntryRepository {
  EntryRepository(this._db);

  final AppDb _db;

  Stream<List<Entry>> watchAll() {
    return _db.watchEntries().map(
          (rows) =>
              rows
                  .map(
                    (r) => Entry(
                      id: r.id,
                      title: r.title,
                      body: r.body,
                      createdAt: r.createdAt,
                      updatedAt: r.updatedAt,
                    ),
                  )
                  .toList(growable: false),
        );
  }

  Future<Entry?> getById(String id) async {
    final r = await _db.getEntry(id);
    if (r == null) return null;
    return Entry(
      id: r.id,
      title: r.title,
      body: r.body,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
    );
  }

  Future<void> save(Entry entry) async {
    await _db.upsertEntry(
      EntriesCompanion.insert(
        id: entry.id,
        createdAt: entry.createdAt,
        updatedAt: entry.updatedAt,
        title: Value(entry.title),
        body: Value(entry.body),
      ),
    );
  }

  Future<void> delete(String id) async {
    await _db.deleteEntryById(id);
  }
}
