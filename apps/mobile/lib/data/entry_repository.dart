import 'package:drift/drift.dart';
import 'package:mobile/data/local/app_db.dart';
import 'package:mobile/domain/entry.dart';
import 'package:mobile/util/date_key.dart';

class EntryRepository {
  EntryRepository(this._db);

  final AppDb _db;

  List<Entry> _mapRows(List<EntryRow> rows) {
    return rows
        .map(
          (r) => Entry(
            id: r.id,
            title: r.title,
            body: r.body,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
          ),
        )
        .toList(growable: false);
  }

  Stream<List<Entry>> watchAll() {
    return _db.watchEntries().map(_mapRows);
  }

  Stream<List<Entry>> watchForDay(DateTime day) {
    return _db.watchEntriesForDayKey(dayKey(day)).map(_mapRows);
  }

  Stream<Map<String, int>> watchDayCountsForMonth(DateTime month) {
    final m = month.toLocal();
    final prefix = '${m.year.toString().padLeft(4, '0')}-${m.month.toString().padLeft(2, '0')}';
    return _db.watchDayCountsForPrefix(prefix);
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
        dayKey: dayKey(entry.createdAt),
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
