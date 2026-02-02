import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PreferencesRepository {
  Future<File> get _file async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/prefs.json');
  }

  Future<Map<String, dynamic>> load() async {
    try {
      final file = await _file;
      if (!await file.exists()) return {};
      final str = await file.readAsString();
      return jsonDecode(str) as Map<String, dynamic>;
    } catch (_) {
      return {};
    }
  }

  Future<void> save(String key, dynamic value) async {
    final file = await _file;
    final current = await load();
    current[key] = value;
    await file.writeAsString(jsonEncode(current));
  }

  Future<String?> getString(String key) async {
    final map = await load();
    return map[key] as String?;
  }
}
