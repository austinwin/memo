import 'dart:convert';

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
            mood: r.mood,
            pinned: r.pinned,
            tags: _decodeStringList(r.tagsJson),
            tasks: _decodeTasks(r.tasksJson),
          ),
        )
        .toList(growable: false);
  }

  List<String> _decodeStringList(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded.map((e) => e.toString()).toList(growable: false);
      }
    } catch (_) {}
    return const <String>[];
  }

  String _encodeStringList(List<String> tags) {
    return jsonEncode(tags);
  }

  List<TaskItem> _decodeTasks(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((m) => TaskItem.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false);
      }
    } catch (_) {}
    return const <TaskItem>[];
  }

  String _encodeTasks(List<TaskItem> tasks) {
    return jsonEncode(tasks.map((t) => t.toJson()).toList(growable: false));
  }

  Stream<List<Entry>> watchAll({String query = ''}) {
    return _db.watchEntries(query: query).map(_mapRows);
  }

  Stream<List<Entry>> watchForDay(DateTime day, {String query = ''}) {
    return _db.watchEntriesForDayKey(dayKey(day), query: query).map(_mapRows);
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
        mood: Value(entry.mood),
        pinned: Value(entry.pinned),
        tagsJson: Value(_encodeStringList(entry.tags)),
        tasksJson: Value(_encodeTasks(entry.tasks)),
      ),
    );
  }

  Future<void> delete(String id) async {
    await _db.deleteEntryById(id);
  }
}
