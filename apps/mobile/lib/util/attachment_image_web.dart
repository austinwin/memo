import 'dart:convert';
import 'package:flutter/material.dart';

Widget buildAttachmentImage(String path, {double? width, double? height, BoxFit fit = BoxFit.cover}) {
  if (path.startsWith('data:')) {
    final base64Data = path.split(',').last;
    final bytes = base64Decode(base64Data);
    return Image.memory(bytes, width: width, height: height, fit: fit);
  }
  return Image.network(path, width: width, height: height, fit: fit);
}
