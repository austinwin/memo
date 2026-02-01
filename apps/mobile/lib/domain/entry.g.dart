// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TaskItem _$TaskItemFromJson(Map<String, dynamic> json) => TaskItem(
  text: json['text'] as String,
  done: json['done'] as bool? ?? false,
);

Map<String, dynamic> _$TaskItemToJson(TaskItem instance) => <String, dynamic>{
  'text': instance.text,
  'done': instance.done,
};

Entry _$EntryFromJson(Map<String, dynamic> json) => Entry(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  mood: (json['mood'] as num?)?.toInt(),
  pinned: json['pinned'] as bool? ?? false,
  tags:
      (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  tasks:
      (json['tasks'] as List<dynamic>?)
          ?.map((e) => TaskItem.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <TaskItem>[],
);

Map<String, dynamic> _$EntryToJson(Entry instance) => <String, dynamic>{
  'id': instance.id,
  'title': instance.title,
  'body': instance.body,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
  'mood': instance.mood,
  'pinned': instance.pinned,
  'tags': instance.tags,
  'tasks': instance.tasks,
};
