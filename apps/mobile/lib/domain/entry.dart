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
class EntryAttachment {
  const EntryAttachment({
    required this.id,
    required this.type,
    required this.path,
    required this.createdAt,
    this.name,
    this.meta,
  });

  /// Unique id for this attachment.
  final String id;

  /// image | video | file | drawing
  final String type;

  /// Local file path.
  final String path;

  /// Display name (optional).
  final String? name;

  final DateTime createdAt;

  /// Arbitrary metadata (e.g. width/height, duration).
  final Map<String, dynamic>? meta;

  factory EntryAttachment.fromJson(Map<String, dynamic> json) =>
      _$EntryAttachmentFromJson(json);
  Map<String, dynamic> toJson() => _$EntryAttachmentToJson(this);
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
    this.isTodo = false,
    this.isDone = false,
    this.lat,
    this.lng,
    this.locationLabel,
    this.locationSymbol,
    this.bodyFormat = 'plain',
    this.bodyDelta,
    this.attachments = const <EntryAttachment>[],
    this.tags = const <String>[],
    this.tasks = const <TaskItem>[],
  });

  final String id;
  final String title;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// PWA parity: Mood (3-level). Stored as String; null = unset.
  final String? mood;

  /// PWA parity: Pin/unpin.
  final bool pinned;
  
  // Tasks (PWA style: the entry itself can be a task)
  final bool isTodo;
  final bool isDone;
  
  // Location
  final double? lat;
  final double? lng;
  // Location Enhancements
  final String? locationLabel; // e.g. "Home", "Office"
  final String? locationSymbol; // e.g. "home", "briefcase", "cafe"

  /// plain | markdown | rich
  final String bodyFormat;

  /// Quill delta JSON string (for rich text)
  final String? bodyDelta;

  /// Attachments (image/video/file/drawing)
  final List<EntryAttachment> attachments;

  /// PWA parity: Tags.
  final List<String> tags;

  /// PWA parity: Tasks/checklist.
  final List<TaskItem> tasks;

  Entry copyWith({
    String? title,
    String? body,
    DateTime? updatedAt,
    String? mood,
    bool? pinned,
    bool? isTodo,
    bool? isDone,
    double? lat,
    double? lng,
    String? locationLabel,
    String? locationSymbol,
    String? bodyFormat,
    String? bodyDelta,
    List<EntryAttachment>? attachments,
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
      isTodo: isTodo ?? this.isTodo,
      isDone: isDone ?? this.isDone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      locationLabel: locationLabel ?? this.locationLabel,
      locationSymbol: locationSymbol ?? this.locationSymbol,
      bodyFormat: bodyFormat ?? this.bodyFormat,
      bodyDelta: bodyDelta ?? this.bodyDelta,
      attachments: attachments ?? this.attachments,
      tags: tags ?? this.tags,
      tasks: tasks ?? this.tasks,
    );
  }

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);
  Map<String, dynamic> toJson() => _$EntryToJson(this);
}
