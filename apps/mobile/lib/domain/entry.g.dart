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

EntryAttachment _$EntryAttachmentFromJson(Map<String, dynamic> json) =>
    EntryAttachment(
      id: json['id'] as String,
      type: json['type'] as String,
      path: json['path'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      name: json['name'] as String?,
      meta: json['meta'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$EntryAttachmentToJson(EntryAttachment instance) =>
    <String, dynamic>{
      'id': instance.id,
      'type': instance.type,
      'path': instance.path,
      'createdAt': instance.createdAt.toIso8601String(),
      'name': instance.name,
      'meta': instance.meta,
    };

Entry _$EntryFromJson(Map<String, dynamic> json) => Entry(
  id: json['id'] as String,
  title: json['title'] as String,
  body: json['body'] as String,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
  mood: json['mood'] as String?,
  pinned: json['pinned'] as bool? ?? false,
  isTodo: json['isTodo'] as bool? ?? false,
  isDone: json['isDone'] as bool? ?? false,
  lat: (json['lat'] as num?)?.toDouble(),
  lng: (json['lng'] as num?)?.toDouble(),
  locationLabel: json['locationLabel'] as String?,
  locationSymbol: json['locationSymbol'] as String?,
  bodyFormat: json['bodyFormat'] as String? ?? 'plain',
  bodyDelta: json['bodyDelta'] as String?,
  attachments:
    (json['attachments'] as List<dynamic>?)
      ?.map((e) => EntryAttachment.fromJson(e as Map<String, dynamic>))
      .toList() ??
    const <EntryAttachment>[],
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
  'isTodo': instance.isTodo,
  'isDone': instance.isDone,
  'lat': instance.lat,
  'lng': instance.lng,
  'locationLabel': instance.locationLabel,
  'locationSymbol': instance.locationSymbol,
  'bodyFormat': instance.bodyFormat,
  'bodyDelta': instance.bodyDelta,
  'attachments': instance.attachments,
  'tags': instance.tags,
  'tasks': instance.tasks,
};
