import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AttachmentStorage {
  Future<String> saveXFile(XFile file, String nameHint) async {
    final bytes = await file.readAsBytes();
    final ext = file.name.split('.').last.toLowerCase();
    final mime = _mimeFromExt(ext);
    return 'data:$mime;base64,${base64Encode(bytes)}';
  }

  Future<String> saveBytes(List<int> bytes, String nameHint, {String ext = '.png'}) async {
    final e = ext.replaceAll('.', '').toLowerCase();
    final mime = _mimeFromExt(e);
    return 'data:$mime;base64,${base64Encode(Uint8List.fromList(bytes))}';
  }

  Future<String> savePath(String path, String nameHint) async {
    // Not supported on web; return path as-is.
    return path;
  }

  String _mimeFromExt(String ext) {
    return switch (ext) {
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'gif' => 'image/gif',
      'mp4' => 'video/mp4',
      'webm' => 'video/webm',
      _ => 'application/octet-stream',
    };
  }
}
