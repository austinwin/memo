import 'dart:convert';

import 'package:isar/isar.dart';
import 'package:mobile/data/local/isar_entry.dart';
import 'package:mobile/domain/entry.dart';
import 'package:mobile/util/date_key.dart';

class EntryRepository {
  EntryRepository(Isar? isar) : _isar = isar ?? (throw ArgumentError('Isar is required'));

  final Isar _isar;

  List<Entry> _mapRows(List<IsarEntry> rows) {
    return rows
        .map(
          (r) => Entry(
            id: r.entryId,
            title: r.title,
            body: r.body,
            createdAt: r.createdAt,
            updatedAt: r.updatedAt,
            mood: r.mood,
            pinned: r.pinned,
            isTodo: r.isTodo,
            isDone: r.isDone,
            lat: r.lat,
            lng: r.lng,
            locationLabel: r.locationLabel,
            locationSymbol: r.locationSymbol,
            bodyFormat: r.bodyFormat,
            bodyDelta: r.bodyDelta,
            attachments: _decodeAttachments(r.attachmentsJson),
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

  List<EntryAttachment> _decodeAttachments(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((m) => EntryAttachment.fromJson(m.cast<String, dynamic>()))
            .toList(growable: false);
      }
    } catch (_) {}
    return const <EntryAttachment>[];
  }

  String _encodeAttachments(List<EntryAttachment> items) {
    return jsonEncode(items.map((t) => t.toJson()).toList(growable: false));
  }

  Stream<List<Entry>> watchAll({String query = ''}) {
    return _isar.isarEntrys
        .watchLazy(fireImmediately: true)
        .asyncMap((_) => _fetchAll(query: query));
  }

  Stream<List<Entry>> watchForDay(DateTime day, {String query = ''}) {
    final key = dayKey(day);
    return _isar.isarEntrys
        .watchLazy(fireImmediately: true)
        .asyncMap((_) async {
          final rows = await _fetchAll(query: query);
          return rows.where((e) => dayKey(e.createdAt) == key).toList();
        });
  }

  Stream<Map<String, int>> watchDayCountsForMonth(DateTime month) {
    final m = month.toLocal();
    final prefix = '${m.year.toString().padLeft(4, '0')}-${m.month.toString().padLeft(2, '0')}';
    return _isar.isarEntrys.watchLazy(fireImmediately: true).asyncMap((_) async {
      final all = await _fetchAll(query: '');
      final map = <String, int>{};
      for (final e in all) {
        final key = dayKey(e.createdAt);
        if (!key.startsWith(prefix)) continue;
        map[key] = (map[key] ?? 0) + 1;
      }
      return map;
    });
  }

  Future<Entry?> getById(String id) async {
    final hash = _fastHash(id);
    final r = await _isar.isarEntrys.get(hash);
    if (r != null && r.entryId == id) return _mapRows([r]).first;

    // Fallback in case of hash collision
    final all = await _isar.isarEntrys.where().anyId().findAll();
    final match = all.where((e) => e.entryId == id).toList();
    if (match.isEmpty) return null;
    return _mapRows([match.first]).first;
  }

  Future<void> save(Entry entry) async {
    final row = IsarEntry()
      ..id = _fastHash(entry.id)
      ..entryId = entry.id
      ..dayKey = dayKey(entry.createdAt)
      ..title = entry.title
      ..body = entry.body
      ..bodyFormat = entry.bodyFormat
      ..bodyDelta = entry.bodyDelta
      ..mood = entry.mood
      ..pinned = entry.pinned
      ..isTodo = entry.isTodo
      ..isDone = entry.isDone
      ..lat = entry.lat
      ..lng = entry.lng
      ..locationLabel = entry.locationLabel
      ..locationSymbol = entry.locationSymbol
      ..tagsJson = _encodeStringList(entry.tags)
      ..tasksJson = _encodeTasks(entry.tasks)
      ..attachmentsJson = _encodeAttachments(entry.attachments)
      ..createdAt = entry.createdAt
      ..updatedAt = entry.updatedAt;

    await _isar.writeTxn(() async {
      await _isar.isarEntrys.put(row);
    });
  }

  Future<void> delete(String id) async {
    final hash = _fastHash(id);
    await _isar.writeTxn(() async {
      await _isar.isarEntrys.delete(hash);
    });
  }

  Future<List<Entry>> _fetchAll({required String query}) async {
    final rows = await _isar.isarEntrys.where().anyId().findAll();
    var entries = _mapRows(rows);

    final q = query.trim().toLowerCase();
    if (q.isNotEmpty) {
      entries = entries
          .where(
            (e) => e.title.toLowerCase().contains(q) || e.body.toLowerCase().contains(q),
          )
          .toList();
    }

    entries.sort((a, b) {
      final pinned = (b.pinned ? 1 : 0).compareTo(a.pinned ? 1 : 0);
      if (pinned != 0) return pinned;
      return b.updatedAt.compareTo(a.updatedAt);
    });

    return entries;
  }

  int _fastHash(String string) {
    return string.hashCode & 0x7fffffff;
  }
}
