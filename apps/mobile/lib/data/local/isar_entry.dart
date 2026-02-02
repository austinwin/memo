import 'package:isar/isar.dart';

part 'isar_entry.g.dart';

@collection
class IsarEntry {
  Id id = Isar.autoIncrement;

  late String entryId;
  late String dayKey;
  late String title;
  late String body;

  late String bodyFormat; // plain | markdown | rich
  String? bodyDelta;

  String? mood;
  late bool pinned;
  late bool isTodo;
  late bool isDone;

  double? lat;
  double? lng;
  String? locationLabel;
  String? locationSymbol;

  late String tagsJson;
  late String tasksJson;
  late String attachmentsJson;

  late DateTime createdAt;
  late DateTime updatedAt;
}
