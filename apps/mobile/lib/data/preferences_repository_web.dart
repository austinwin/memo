import 'dart:convert';
import 'dart:html' as html;

class PreferencesRepository {
  static const _storageKey = 'memo_prefs';

  Future<Map<String, dynamic>> load() async {
    try {
      final raw = html.window.localStorage[_storageKey];
      if (raw == null || raw.isEmpty) return {};
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return {};
    } catch (_) {
      return {};
    }
  }

  Future<void> save(String key, dynamic value) async {
    final current = await load();
    current[key] = value;
    html.window.localStorage[_storageKey] = jsonEncode(current);
  }

  Future<String?> getString(String key) async {
    final map = await load();
    return map[key] as String?;
  }
}
