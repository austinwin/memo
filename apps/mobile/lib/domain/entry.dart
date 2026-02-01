import 'package:json_annotation/json_annotation.dart';

part 'entry.g.dart';

/// Core domain model for a journal entry.
///
/// Mobile-first: keep it simple and fast.
@JsonSerializable()
class Entry {
  const Entry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  Entry copyWith({
    String? title,
    String? body,
    DateTime? updatedAt,
  }) {
    return Entry(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
  Map<String, dynamic> toJson() => _$EntryToJson(this);
}
