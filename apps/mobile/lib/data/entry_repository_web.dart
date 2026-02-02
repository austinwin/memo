import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

import 'package:isar/isar.dart';
import 'package:mobile/domain/entry.dart';
import 'package:mobile/util/date_key.dart';

class EntryRepository {
  EntryRepository(Isar? _);

  static const _storageKey = 'memo_entries';
  final _changes = StreamController<void>.broadcast();

  void _notify() {
    if (!_changes.isClosed) {
      _changes.add(null);
    }
  }

  List<Entry> _loadAll() {
    try {
      final raw = html.window.localStorage[_storageKey];
      if (raw == null || raw.isEmpty) return <Entry>[];
      final decoded = jsonDecode(raw);
      if (decoded is List) {
        return decoded
            .whereType<Map>()
            .map((m) => Entry.fromJson(m.cast<String, dynamic>()))
            .toList();
      }
    } catch (_) {}
    return <Entry>[];
  }

  Future<void> _saveAll(List<Entry> entries) async {
    html.window.localStorage[_storageKey] = jsonEncode(
      entries.map((e) => e.toJson()).toList(growable: false),
    );
  }

  Stream<List<Entry>> watchAll({String query = ''}) async* {
    yield await _fetchAll(query: query);
    yield* _changes.stream.asyncMap((_) => _fetchAll(query: query));
  }

  Stream<List<Entry>> watchForDay(DateTime day, {String query = ''}) async* {
    final key = dayKey(day);
    yield (await _fetchAll(query: query))
        .where((e) => dayKey(e.createdAt) == key)
        .toList();
    yield* _changes.stream.asyncMap((_) async {
      final rows = await _fetchAll(query: query);
      return rows.where((e) => dayKey(e.createdAt) == key).toList();
    });
  }

  Stream<Map<String, int>> watchDayCountsForMonth(DateTime month) async* {
    final m = month.toLocal();
    final prefix = '${m.year.toString().padLeft(4, '0')}-${m.month.toString().padLeft(2, '0')}';
    Future<Map<String, int>> compute() async {
      final all = await _fetchAll(query: '');
      final map = <String, int>{};
      for (final e in all) {
        final key = dayKey(e.createdAt);
        if (!key.startsWith(prefix)) continue;
        map[key] = (map[key] ?? 0) + 1;
      }
      return map;
    }

    yield await compute();
    yield* _changes.stream.asyncMap((_) => compute());
  }

  Future<Entry?> getById(String id) async {
    final all = _loadAll();
    try {
      return all.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  Future<void> save(Entry entry) async {
    final all = _loadAll();
    final idx = all.indexWhere((e) => e.id == entry.id);
    if (idx >= 0) {
      all[idx] = entry;
    } else {
      all.add(entry);
    }
    await _saveAll(all);
    _notify();
  }

  Future<void> delete(String id) async {
    final all = _loadAll();
    all.removeWhere((e) => e.id == id);
    await _saveAll(all);
    _notify();
  }

  Future<List<Entry>> _fetchAll({required String query}) async {
    var entries = _loadAll();

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
}
