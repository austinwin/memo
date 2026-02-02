/* Drift removed. Legacy file retained to avoid stale imports.
// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_db.dart';

// ignore_for_file: type=lint
class $EntriesTable extends Entries with TableInfo<$EntriesTable, EntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EntriesTable(this.attachedDatabase, [this._alias]);
  // Drift removed. This file is kept as an empty placeholder to avoid stale imports.
  final String bodyFormat;
  final String? bodyDelta;
  final String? mood;
  final bool pinned;
  final bool isTodo;
  final bool isDone;
  final double? lat;
  final double? lng;
  final String? locationLabel;
  final String? locationSymbol;
  final String tagsJson;
  final String tasksJson;
  final String attachmentsJson;
  final DateTime createdAt;
  final DateTime updatedAt;
  const EntryRow({
    required this.id,
    required this.dayKey,
    required this.title,
    required this.body,
    required this.bodyFormat,
    this.bodyDelta,
    this.mood,
    required this.pinned,
    required this.isTodo,
    required this.isDone,
    this.lat,
    this.lng,
    this.locationLabel,
    this.locationSymbol,
    required this.tagsJson,
    required this.tasksJson,
    required this.attachmentsJson,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['day_key'] = Variable<String>(dayKey);
    map['title'] = Variable<String>(title);
    map['body'] = Variable<String>(body);
    map['body_format'] = Variable<String>(bodyFormat);
    if (!nullToAbsent || bodyDelta != null) {
      map['body_delta'] = Variable<String>(bodyDelta);
    }
    if (!nullToAbsent || mood != null) {
      map['mood'] = Variable<String>(mood);
    }
    map['pinned'] = Variable<bool>(pinned);
    map['is_todo'] = Variable<bool>(isTodo);
    map['is_done'] = Variable<bool>(isDone);
    if (!nullToAbsent || lat != null) {
      map['lat'] = Variable<double>(lat);
    }
    if (!nullToAbsent || lng != null) {
      map['lng'] = Variable<double>(lng);
    }
    if (!nullToAbsent || locationLabel != null) {
      map['location_label'] = Variable<String>(locationLabel);
    }
    if (!nullToAbsent || locationSymbol != null) {
      map['location_symbol'] = Variable<String>(locationSymbol);
    }
    map['tags_json'] = Variable<String>(tagsJson);
    map['tasks_json'] = Variable<String>(tasksJson);
    map['attachments_json'] = Variable<String>(attachmentsJson);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EntriesCompanion toCompanion(bool nullToAbsent) {
    return EntriesCompanion(
      id: Value(id),
      dayKey: Value(dayKey),
      title: Value(title),
      body: Value(body),
        bodyFormat: Value(bodyFormat),
        bodyDelta:
          bodyDelta == null && nullToAbsent
            ? const Value.absent()
            : Value(bodyDelta),
      mood: mood == null && nullToAbsent ? const Value.absent() : Value(mood),
      pinned: Value(pinned),
      isTodo: Value(isTodo),
      isDone: Value(isDone),
      lat: lat == null && nullToAbsent ? const Value.absent() : Value(lat),
      lng: lng == null && nullToAbsent ? const Value.absent() : Value(lng),
        locationLabel:
          locationLabel == null && nullToAbsent
            ? const Value.absent()
            : Value(locationLabel),
        locationSymbol:
          locationSymbol == null && nullToAbsent
            ? const Value.absent()
            : Value(locationSymbol),
      tagsJson: Value(tagsJson),
      tasksJson: Value(tasksJson),
        attachmentsJson: Value(attachmentsJson),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory EntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EntryRow(
      id: serializer.fromJson<String>(json['id']),
      dayKey: serializer.fromJson<String>(json['dayKey']),
      title: serializer.fromJson<String>(json['title']),
      body: serializer.fromJson<String>(json['body']),
      bodyFormat: serializer.fromJson<String>(json['bodyFormat']),
      bodyDelta: serializer.fromJson<String?>(json['bodyDelta']),
      mood: serializer.fromJson<String?>(json['mood']),
      pinned: serializer.fromJson<bool>(json['pinned']),
      isTodo: serializer.fromJson<bool>(json['isTodo']),
      isDone: serializer.fromJson<bool>(json['isDone']),
      lat: serializer.fromJson<double?>(json['lat']),
      lng: serializer.fromJson<double?>(json['lng']),
      locationLabel: serializer.fromJson<String?>(json['locationLabel']),
      locationSymbol: serializer.fromJson<String?>(json['locationSymbol']),
      tagsJson: serializer.fromJson<String>(json['tagsJson']),
      tasksJson: serializer.fromJson<String>(json['tasksJson']),
      attachmentsJson: serializer.fromJson<String>(json['attachmentsJson']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'dayKey': serializer.toJson<String>(dayKey),
      'title': serializer.toJson<String>(title),
      'body': serializer.toJson<String>(body),
      'bodyFormat': serializer.toJson<String>(bodyFormat),
      'bodyDelta': serializer.toJson<String?>(bodyDelta),
      'mood': serializer.toJson<String?>(mood),
      'pinned': serializer.toJson<bool>(pinned),
      'isTodo': serializer.toJson<bool>(isTodo),
      'isDone': serializer.toJson<bool>(isDone),
      'lat': serializer.toJson<double?>(lat),
      'lng': serializer.toJson<double?>(lng),
      'locationLabel': serializer.toJson<String?>(locationLabel),
      'locationSymbol': serializer.toJson<String?>(locationSymbol),
      'tagsJson': serializer.toJson<String>(tagsJson),
      'tasksJson': serializer.toJson<String>(tasksJson),
      'attachmentsJson': serializer.toJson<String>(attachmentsJson),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EntryRow copyWith({
    String? id,
    String? dayKey,
    String? title,
    String? body,
    String? bodyFormat,
    Value<String?> bodyDelta = const Value.absent(),
    Value<String?> mood = const Value.absent(),
    bool? pinned,
    bool? isTodo,
    bool? isDone,
    Value<double?> lat = const Value.absent(),
    Value<double?> lng = const Value.absent(),
    Value<String?> locationLabel = const Value.absent(),
    Value<String?> locationSymbol = const Value.absent(),
    String? tagsJson,
    String? tasksJson,
    String? attachmentsJson,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => EntryRow(
    id: id ?? this.id,
    dayKey: dayKey ?? this.dayKey,
    title: title ?? this.title,
    body: body ?? this.body,
    bodyFormat: bodyFormat ?? this.bodyFormat,
    bodyDelta: bodyDelta.present ? bodyDelta.value : this.bodyDelta,
    mood: mood.present ? mood.value : this.mood,
    pinned: pinned ?? this.pinned,
    isTodo: isTodo ?? this.isTodo,
    isDone: isDone ?? this.isDone,
    lat: lat.present ? lat.value : this.lat,
    lng: lng.present ? lng.value : this.lng,
    locationLabel:
        locationLabel.present ? locationLabel.value : this.locationLabel,
    locationSymbol:
        locationSymbol.present ? locationSymbol.value : this.locationSymbol,
    tagsJson: tagsJson ?? this.tagsJson,
    tasksJson: tasksJson ?? this.tasksJson,
    attachmentsJson: attachmentsJson ?? this.attachmentsJson,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EntryRow copyWithCompanion(EntriesCompanion data) {
    return EntryRow(
      id: data.id.present ? data.id.value : this.id,
      dayKey: data.dayKey.present ? data.dayKey.value : this.dayKey,
      title: data.title.present ? data.title.value : this.title,
      body: data.body.present ? data.body.value : this.body,
        bodyFormat:
          data.bodyFormat.present ? data.bodyFormat.value : this.bodyFormat,
        bodyDelta: data.bodyDelta.present ? data.bodyDelta.value : this.bodyDelta,
      mood: data.mood.present ? data.mood.value : this.mood,
      pinned: data.pinned.present ? data.pinned.value : this.pinned,
      isTodo: data.isTodo.present ? data.isTodo.value : this.isTodo,
      isDone: data.isDone.present ? data.isDone.value : this.isDone,
      lat: data.lat.present ? data.lat.value : this.lat,
      lng: data.lng.present ? data.lng.value : this.lng,
        locationLabel:
          data.locationLabel.present
            ? data.locationLabel.value
            : this.locationLabel,
        locationSymbol:
          data.locationSymbol.present
            ? data.locationSymbol.value
            : this.locationSymbol,
      tagsJson: data.tagsJson.present ? data.tagsJson.value : this.tagsJson,
      tasksJson: data.tasksJson.present ? data.tasksJson.value : this.tasksJson,
        attachmentsJson:
          data.attachmentsJson.present
            ? data.attachmentsJson.value
            : this.attachmentsJson,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EntryRow(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('bodyFormat: $bodyFormat, ')
          ..write('bodyDelta: $bodyDelta, ')
          ..write('mood: $mood, ')
          ..write('pinned: $pinned, ')
          ..write('isTodo: $isTodo, ')
          ..write('isDone: $isDone, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('locationSymbol: $locationSymbol, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('tasksJson: $tasksJson, ')
          ..write('attachmentsJson: $attachmentsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    dayKey,
    title,
    body,
    bodyFormat,
    bodyDelta,
    mood,
    pinned,
    isTodo,
    isDone,
    lat,
    lng,
    locationLabel,
    locationSymbol,
    tagsJson,
    tasksJson,
    attachmentsJson,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EntryRow &&
          other.id == this.id &&
          other.dayKey == this.dayKey &&
          other.title == this.title &&
          other.body == this.body &&
          other.bodyFormat == this.bodyFormat &&
          other.bodyDelta == this.bodyDelta &&
          other.mood == this.mood &&
          other.pinned == this.pinned &&
          other.isTodo == this.isTodo &&
          other.isDone == this.isDone &&
          other.lat == this.lat &&
          other.lng == this.lng &&
          other.locationLabel == this.locationLabel &&
          other.locationSymbol == this.locationSymbol &&
          other.tagsJson == this.tagsJson &&
          other.tasksJson == this.tasksJson &&
          other.attachmentsJson == this.attachmentsJson &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class EntriesCompanion extends UpdateCompanion<EntryRow> {
  final Value<String> id;
  final Value<String> dayKey;
  final Value<String> title;
  final Value<String> body;
  final Value<String> bodyFormat;
  final Value<String?> bodyDelta;
  final Value<String?> mood;
  final Value<bool> pinned;
  final Value<bool> isTodo;
  final Value<bool> isDone;
  final Value<double?> lat;
  final Value<double?> lng;
  final Value<String?> locationLabel;
  final Value<String?> locationSymbol;
  final Value<String> tagsJson;
  final Value<String> tasksJson;
  final Value<String> attachmentsJson;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const EntriesCompanion({
    this.id = const Value.absent(),
    this.dayKey = const Value.absent(),
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.bodyFormat = const Value.absent(),
    this.bodyDelta = const Value.absent(),
    this.mood = const Value.absent(),
    this.pinned = const Value.absent(),
    this.isTodo = const Value.absent(),
    this.isDone = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.locationSymbol = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.tasksJson = const Value.absent(),
    this.attachmentsJson = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  EntriesCompanion.insert({
    required String id,
    required String dayKey,
    this.title = const Value.absent(),
    this.body = const Value.absent(),
    this.bodyFormat = const Value.absent(),
    this.bodyDelta = const Value.absent(),
    this.mood = const Value.absent(),
    this.pinned = const Value.absent(),
    this.isTodo = const Value.absent(),
    this.isDone = const Value.absent(),
    this.lat = const Value.absent(),
    this.lng = const Value.absent(),
    this.locationLabel = const Value.absent(),
    this.locationSymbol = const Value.absent(),
    this.tagsJson = const Value.absent(),
    this.tasksJson = const Value.absent(),
    this.attachmentsJson = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       dayKey = Value(dayKey),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<EntryRow> custom({
    Expression<String>? id,
    Expression<String>? dayKey,
    Expression<String>? title,
    Expression<String>? body,
    Expression<String>? bodyFormat,
    Expression<String>? bodyDelta,
    Expression<String>? mood,
    Expression<bool>? pinned,
    Expression<bool>? isTodo,
    Expression<bool>? isDone,
    Expression<double>? lat,
    Expression<double>? lng,
    Expression<String>? locationLabel,
    Expression<String>? locationSymbol,
    Expression<String>? tagsJson,
    Expression<String>? tasksJson,
    Expression<String>? attachmentsJson,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (dayKey != null) 'day_key': dayKey,
      if (title != null) 'title': title,
      if (body != null) 'body': body,
      if (bodyFormat != null) 'body_format': bodyFormat,
      if (bodyDelta != null) 'body_delta': bodyDelta,
      if (mood != null) 'mood': mood,
      if (pinned != null) 'pinned': pinned,
      if (isTodo != null) 'is_todo': isTodo,
      if (isDone != null) 'is_done': isDone,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (locationLabel != null) 'location_label': locationLabel,
      if (locationSymbol != null) 'location_symbol': locationSymbol,
      if (tagsJson != null) 'tags_json': tagsJson,
      if (tasksJson != null) 'tasks_json': tasksJson,
      if (attachmentsJson != null) 'attachments_json': attachmentsJson,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  EntriesCompanion copyWith({
    Value<String>? id,
    Value<String>? dayKey,
    Value<String>? title,
    Value<String>? body,
    Value<String>? bodyFormat,
    Value<String?>? bodyDelta,
    Value<String?>? mood,
    Value<bool>? pinned,
    Value<bool>? isTodo,
    Value<bool>? isDone,
    Value<double?>? lat,
    Value<double?>? lng,
    Value<String?>? locationLabel,
    Value<String?>? locationSymbol,
    Value<String>? tagsJson,
    Value<String>? tasksJson,
    Value<String>? attachmentsJson,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return EntriesCompanion(
      id: id ?? this.id,
      dayKey: dayKey ?? this.dayKey,
      title: title ?? this.title,
      body: body ?? this.body,
      bodyFormat: bodyFormat ?? this.bodyFormat,
      bodyDelta: bodyDelta ?? this.bodyDelta,
      mood: mood ?? this.mood,
      pinned: pinned ?? this.pinned,
      isTodo: isTodo ?? this.isTodo,
      isDone: isDone ?? this.isDone,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      locationLabel: locationLabel ?? this.locationLabel,
      locationSymbol: locationSymbol ?? this.locationSymbol,
      tagsJson: tagsJson ?? this.tagsJson,
      tasksJson: tasksJson ?? this.tasksJson,
      attachmentsJson: attachmentsJson ?? this.attachmentsJson,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (dayKey.present) {
      map['day_key'] = Variable<String>(dayKey.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (bodyFormat.present) {
      map['body_format'] = Variable<String>(bodyFormat.value);
    }
    if (bodyDelta.present) {
      map['body_delta'] = Variable<String>(bodyDelta.value);
    }
    if (mood.present) {
      map['mood'] = Variable<String>(mood.value);
    }
    if (pinned.present) {
      map['pinned'] = Variable<bool>(pinned.value);
    }
    if (isTodo.present) {
      map['is_todo'] = Variable<bool>(isTodo.value);
    }
    if (isDone.present) {
      map['is_done'] = Variable<bool>(isDone.value);
    }
    if (lat.present) {
      map['lat'] = Variable<double>(lat.value);
    }
    if (lng.present) {
      map['lng'] = Variable<double>(lng.value);
    }
    if (locationLabel.present) {
      map['location_label'] = Variable<String>(locationLabel.value);
    }
    if (locationSymbol.present) {
      map['location_symbol'] = Variable<String>(locationSymbol.value);
    }
    if (tagsJson.present) {
      map['tags_json'] = Variable<String>(tagsJson.value);
    }
    if (tasksJson.present) {
      map['tasks_json'] = Variable<String>(tasksJson.value);
    }
    if (attachmentsJson.present) {
      map['attachments_json'] = Variable<String>(attachmentsJson.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EntriesCompanion(')
          ..write('id: $id, ')
          ..write('dayKey: $dayKey, ')
          ..write('title: $title, ')
          ..write('body: $body, ')
          ..write('bodyFormat: $bodyFormat, ')
          ..write('bodyDelta: $bodyDelta, ')
          ..write('mood: $mood, ')
          ..write('pinned: $pinned, ')
          ..write('isTodo: $isTodo, ')
          ..write('isDone: $isDone, ')
          ..write('lat: $lat, ')
          ..write('lng: $lng, ')
          ..write('locationLabel: $locationLabel, ')
          ..write('locationSymbol: $locationSymbol, ')
          ..write('tagsJson: $tagsJson, ')
          ..write('tasksJson: $tasksJson, ')
          ..write('attachmentsJson: $attachmentsJson, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDb extends GeneratedDatabase {
  _$AppDb(QueryExecutor e) : super(e);
  $AppDbManager get managers => $AppDbManager(this);
  late final $EntriesTable entries = $EntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [entries];
}

typedef $$EntriesTableCreateCompanionBuilder =
    EntriesCompanion Function({
      required String id,
      required String dayKey,
      Value<String> title,
      Value<String> body,
      Value<String?> mood,
      Value<bool> pinned,
      Value<bool> isTodo,
      Value<bool> isDone,
      Value<double?> lat,
      Value<double?> lng,
      Value<String> tagsJson,
      Value<String> tasksJson,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$EntriesTableUpdateCompanionBuilder =
    EntriesCompanion Function({
      Value<String> id,
      Value<String> dayKey,
      Value<String> title,
      Value<String> body,
      Value<String?> mood,
      Value<bool> pinned,
      Value<bool> isTodo,
      Value<bool> isDone,
      Value<double?> lat,
      Value<double?> lng,
      Value<String> tagsJson,
      Value<String> tasksJson,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$EntriesTableFilterComposer extends Composer<_$AppDb, $EntriesTable> {
  $$EntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTodo => $composableBuilder(
    column: $table.isTodo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tasksJson => $composableBuilder(
    column: $table.tasksJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$EntriesTableOrderingComposer extends Composer<_$AppDb, $EntriesTable> {
  $$EntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dayKey => $composableBuilder(
    column: $table.dayKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mood => $composableBuilder(
    column: $table.mood,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get pinned => $composableBuilder(
    column: $table.pinned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTodo => $composableBuilder(
    column: $table.isTodo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isDone => $composableBuilder(
    column: $table.isDone,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lat => $composableBuilder(
    column: $table.lat,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get lng => $composableBuilder(
    column: $table.lng,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tagsJson => $composableBuilder(
    column: $table.tagsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tasksJson => $composableBuilder(
    column: $table.tasksJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$EntriesTableAnnotationComposer
    extends Composer<_$AppDb, $EntriesTable> {
  $$EntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get dayKey =>
      $composableBuilder(column: $table.dayKey, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<String> get mood =>
      $composableBuilder(column: $table.mood, builder: (column) => column);

  GeneratedColumn<bool> get pinned =>
      $composableBuilder(column: $table.pinned, builder: (column) => column);

  GeneratedColumn<bool> get isTodo =>
      $composableBuilder(column: $table.isTodo, builder: (column) => column);

  GeneratedColumn<bool> get isDone =>
      $composableBuilder(column: $table.isDone, builder: (column) => column);

  GeneratedColumn<double> get lat =>
      $composableBuilder(column: $table.lat, builder: (column) => column);

  GeneratedColumn<double> get lng =>
      $composableBuilder(column: $table.lng, builder: (column) => column);

  GeneratedColumn<String> get tagsJson =>
      $composableBuilder(column: $table.tagsJson, builder: (column) => column);

  GeneratedColumn<String> get tasksJson =>
      $composableBuilder(column: $table.tasksJson, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$EntriesTableTableManager
    extends
        RootTableManager<
          _$AppDb,
          $EntriesTable,
          EntryRow,
          $$EntriesTableFilterComposer,
          $$EntriesTableOrderingComposer,
          $$EntriesTableAnnotationComposer,
          $$EntriesTableCreateCompanionBuilder,
          $$EntriesTableUpdateCompanionBuilder,
          (EntryRow, BaseReferences<_$AppDb, $EntriesTable, EntryRow>),
          EntryRow,
          PrefetchHooks Function()
        > {
  $$EntriesTableTableManager(_$AppDb db, $EntriesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> dayKey = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> isTodo = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> tasksJson = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion(
                id: id,
                dayKey: dayKey,
                title: title,
                body: body,
                mood: mood,
                pinned: pinned,
                isTodo: isTodo,
                isDone: isDone,
                lat: lat,
                lng: lng,
                tagsJson: tagsJson,
                tasksJson: tasksJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String dayKey,
                Value<String> title = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<String?> mood = const Value.absent(),
                Value<bool> pinned = const Value.absent(),
                Value<bool> isTodo = const Value.absent(),
                Value<bool> isDone = const Value.absent(),
                Value<double?> lat = const Value.absent(),
                Value<double?> lng = const Value.absent(),
                Value<String> tagsJson = const Value.absent(),
                Value<String> tasksJson = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => EntriesCompanion.insert(
                id: id,
                dayKey: dayKey,
                title: title,
                body: body,
                mood: mood,
                pinned: pinned,
                isTodo: isTodo,
                isDone: isDone,
                lat: lat,
                lng: lng,
                tagsJson: tagsJson,
                tasksJson: tasksJson,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$EntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDb,
      $EntriesTable,
      EntryRow,
      $$EntriesTableFilterComposer,
      $$EntriesTableOrderingComposer,
      $$EntriesTableAnnotationComposer,
      $$EntriesTableCreateCompanionBuilder,
      $$EntriesTableUpdateCompanionBuilder,
      (EntryRow, BaseReferences<_$AppDb, $EntriesTable, EntryRow>),
      EntryRow,
      PrefetchHooks Function()
    >;

class $AppDbManager {
  final _$AppDb _db;
  $AppDbManager(this._db);
  $$EntriesTableTableManager get entries =>
      $$EntriesTableTableManager(_db, _db.entries);
}
*/
