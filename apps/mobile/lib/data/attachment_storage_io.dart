import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class AttachmentStorage {
  Future<Directory> _baseDir() async {
    final dir = await getApplicationDocumentsDirectory();
    final target = Directory(p.join(dir.path, 'attachments'));
    if (!await target.exists()) {
      await target.create(recursive: true);
    }
    return target;
  }

  Future<String> saveXFile(XFile file, String nameHint) async {
    final dir = await _baseDir();
    final ext = p.extension(file.path);
    final base = nameHint.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename = '$base-${DateTime.now().millisecondsSinceEpoch}$ext';
    final target = File(p.join(dir.path, filename));
    await File(file.path).copy(target.path);
    return target.path;
  }

  Future<String> saveBytes(List<int> bytes, String nameHint, {String ext = '.png'}) async {
    final dir = await _baseDir();
    final base = nameHint.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename = '$base-${DateTime.now().millisecondsSinceEpoch}$ext';
    final target = File(p.join(dir.path, filename));
    await target.writeAsBytes(bytes, flush: true);
    return target.path;
  }

  Future<String> savePath(String path, String nameHint) async {
    final dir = await _baseDir();
    final ext = p.extension(path);
    final base = nameHint.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    final filename = '$base-${DateTime.now().millisecondsSinceEpoch}$ext';
    final target = File(p.join(dir.path, filename));
    await File(path).copy(target.path);
    return target.path;
  }
}
