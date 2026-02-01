import 'package:json_annotation/json_annotation.dart';

part 'entry.g.dart';

/// Core domain model for a journal entry.
///
/// Mobile-first: keep it simple and fast.

@JsonSerializable()
class TaskItem {
  const TaskItem({required this.text, this.done = false});

  final String text;
  final bool done;

  TaskItem copyWith({String? text, bool? done}) {
    return TaskItem(text: text ?? this.text, done: done ?? this.done);
  }

  factory TaskItem.fromJson(Map<String, dynamic> json) =>
      _$TaskItemFromJson(json);
  Map<String, dynamic> toJson() => _$TaskItemToJson(this);
}

@JsonSerializable()
class Entry {
  const Entry({
    required this.id,
    required this.title,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
    this.mood,
    this.pinned = false,
    this.tags = const <String>[],
    this.tasks = const <TaskItem>[],
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// PWA parity: Mood (3-level). Stored as 0..2; null = unset.
  final int? mood;

  /// PWA parity: Pin/unpin.
  final bool pinned;

  /// PWA parity: Tags.
  final List<String> tags;

  /// PWA parity: Tasks/checklist.
  final List<TaskItem> tasks;

  Entry copyWith({
    String? title,
    String? body,
    DateTime? updatedAt,
    int? mood,
    bool? pinned,
    List<String>? tags,
    List<TaskItem>? tasks,
  }) {
    return Entry(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      mood: mood ?? this.mood,
      pinned: pinned ?? this.pinned,
      tags: tags ?? this.tags,
      tasks: tasks ?? this.tasks,
    );
  }

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
  Map<String, dynamic> toJson() => _$EntryToJson(this);
}
