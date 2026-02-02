// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'isar_entry.dart';

// ignore_for_file: type=lint

extension GetIsarEntryCollection on Isar {
  IsarCollection<IsarEntry> get isarEntrys => this.collection();
}

const IsarEntrySchema = CollectionSchema(
  name: r'IsarEntry',
  id: 8134516327450123,
  properties: {
    r'entryId': PropertySchema(id: 0, name: r'entryId', type: IsarType.string),
    r'dayKey': PropertySchema(id: 1, name: r'dayKey', type: IsarType.string),
    r'title': PropertySchema(id: 2, name: r'title', type: IsarType.string),
    r'body': PropertySchema(id: 3, name: r'body', type: IsarType.string),
    r'bodyFormat': PropertySchema(id: 4, name: r'bodyFormat', type: IsarType.string),
    r'bodyDelta': PropertySchema(id: 5, name: r'bodyDelta', type: IsarType.string),
    r'mood': PropertySchema(id: 6, name: r'mood', type: IsarType.string),
    r'pinned': PropertySchema(id: 7, name: r'pinned', type: IsarType.bool),
    r'isTodo': PropertySchema(id: 8, name: r'isTodo', type: IsarType.bool),
    r'isDone': PropertySchema(id: 9, name: r'isDone', type: IsarType.bool),
    r'lat': PropertySchema(id: 10, name: r'lat', type: IsarType.double),
    r'lng': PropertySchema(id: 11, name: r'lng', type: IsarType.double),
    r'locationLabel': PropertySchema(id: 12, name: r'locationLabel', type: IsarType.string),
    r'locationSymbol': PropertySchema(id: 13, name: r'locationSymbol', type: IsarType.string),
    r'tagsJson': PropertySchema(id: 14, name: r'tagsJson', type: IsarType.string),
    r'tasksJson': PropertySchema(id: 15, name: r'tasksJson', type: IsarType.string),
    r'attachmentsJson': PropertySchema(id: 16, name: r'attachmentsJson', type: IsarType.string),
    r'createdAt': PropertySchema(id: 17, name: r'createdAt', type: IsarType.dateTime),
    r'updatedAt': PropertySchema(id: 18, name: r'updatedAt', type: IsarType.dateTime),
  },
  estimateSize: _isarEntryEstimateSize,
  serialize: _isarEntrySerialize,
  deserialize: _isarEntryDeserialize,
  deserializeProp: _isarEntryDeserializeProp,
  idName: r'id',
  indexes: {},
  links: {},
  embeddedSchemas: {},
  getId: _isarEntryGetId,
  getLinks: _isarEntryGetLinks,
  attach: _isarEntryAttach,
  version: '3.1.0+1',
);

int _isarEntryEstimateSize(IsarEntry object, List<int> offsets, Map<Type, List<int>> allOffsets) {
  var bytesCount = offsets.last;
  bytesCount += 3 + object.entryId.length * 3;
  bytesCount += 3 + object.dayKey.length * 3;
  bytesCount += 3 + object.title.length * 3;
  bytesCount += 3 + object.body.length * 3;
  bytesCount += 3 + object.bodyFormat.length * 3;
  final bodyDelta = object.bodyDelta;
  if (bodyDelta != null) {
    bytesCount += 3 + bodyDelta.length * 3;
  }
  final mood = object.mood;
  if (mood != null) {
    bytesCount += 3 + mood.length * 3;
  }
  final locationLabel = object.locationLabel;
  if (locationLabel != null) {
    bytesCount += 3 + locationLabel.length * 3;
  }
  final locationSymbol = object.locationSymbol;
  if (locationSymbol != null) {
    bytesCount += 3 + locationSymbol.length * 3;
  }
  bytesCount += 3 + object.tagsJson.length * 3;
  bytesCount += 3 + object.tasksJson.length * 3;
  bytesCount += 3 + object.attachmentsJson.length * 3;
  return bytesCount;
}

void _isarEntrySerialize(IsarEntry object, IsarWriter writer, List<int> offsets, Map<Type, List<int>> allOffsets) {
  writer.writeString(offsets[0], object.entryId);
  writer.writeString(offsets[1], object.dayKey);
  writer.writeString(offsets[2], object.title);
  writer.writeString(offsets[3], object.body);
  writer.writeString(offsets[4], object.bodyFormat);
  writer.writeString(offsets[5], object.bodyDelta);
  writer.writeString(offsets[6], object.mood);
  writer.writeBool(offsets[7], object.pinned);
  writer.writeBool(offsets[8], object.isTodo);
  writer.writeBool(offsets[9], object.isDone);
  writer.writeDouble(offsets[10], object.lat);
  writer.writeDouble(offsets[11], object.lng);
  writer.writeString(offsets[12], object.locationLabel);
  writer.writeString(offsets[13], object.locationSymbol);
  writer.writeString(offsets[14], object.tagsJson);
  writer.writeString(offsets[15], object.tasksJson);
  writer.writeString(offsets[16], object.attachmentsJson);
  writer.writeDateTime(offsets[17], object.createdAt);
  writer.writeDateTime(offsets[18], object.updatedAt);
}

IsarEntry _isarEntryDeserialize(Id id, IsarReader reader, List<int> offsets, Map<Type, List<int>> allOffsets) {
  final object = IsarEntry();
  object.id = id;
  object.entryId = reader.readString(offsets[0]);
  object.dayKey = reader.readString(offsets[1]);
  object.title = reader.readString(offsets[2]);
  object.body = reader.readString(offsets[3]);
  object.bodyFormat = reader.readString(offsets[4]);
  object.bodyDelta = reader.readStringOrNull(offsets[5]);
  object.mood = reader.readStringOrNull(offsets[6]);
  object.pinned = reader.readBool(offsets[7]);
  object.isTodo = reader.readBool(offsets[8]);
  object.isDone = reader.readBool(offsets[9]);
  object.lat = reader.readDoubleOrNull(offsets[10]);
  object.lng = reader.readDoubleOrNull(offsets[11]);
  object.locationLabel = reader.readStringOrNull(offsets[12]);
  object.locationSymbol = reader.readStringOrNull(offsets[13]);
  object.tagsJson = reader.readString(offsets[14]);
  object.tasksJson = reader.readString(offsets[15]);
  object.attachmentsJson = reader.readString(offsets[16]);
  object.createdAt = reader.readDateTime(offsets[17]);
  object.updatedAt = reader.readDateTime(offsets[18]);
  return object;
}

P _isarEntryDeserializeProp<P>(IsarReader reader, int propertyId, int offset, Map<Type, List<int>> allOffsets) {
  switch (propertyId) {
    case 0:
      return reader.readString(offset) as P;
    case 1:
      return reader.readString(offset) as P;
    case 2:
      return reader.readString(offset) as P;
    case 3:
      return reader.readString(offset) as P;
    case 4:
      return reader.readString(offset) as P;
    case 5:
      return reader.readStringOrNull(offset) as P;
    case 6:
      return reader.readStringOrNull(offset) as P;
    case 7:
      return reader.readBool(offset) as P;
    case 8:
      return reader.readBool(offset) as P;
    case 9:
      return reader.readBool(offset) as P;
    case 10:
      return reader.readDoubleOrNull(offset) as P;
    case 11:
      return reader.readDoubleOrNull(offset) as P;
    case 12:
      return reader.readStringOrNull(offset) as P;
    case 13:
      return reader.readStringOrNull(offset) as P;
    case 14:
      return reader.readString(offset) as P;
    case 15:
      return reader.readString(offset) as P;
    case 16:
      return reader.readString(offset) as P;
    case 17:
      return reader.readDateTime(offset) as P;
    case 18:
      return reader.readDateTime(offset) as P;
    default:
      throw IsarError('Unknown property with id $propertyId');
  }
}

Id _isarEntryGetId(IsarEntry object) {
  return object.id;
}

List<IsarLinkBase<dynamic>> _isarEntryGetLinks(IsarEntry object) {
  return [];
}

void _isarEntryAttach(IsarCollection<dynamic> col, Id id, IsarEntry object) {
  object.id = id;
}

extension IsarEntryQueryWhereSort on QueryBuilder<IsarEntry, IsarEntry, QWhere> {
  QueryBuilder<IsarEntry, IsarEntry, QAfterWhere> anyId() {
    return QueryBuilder.apply(this, (q) => q.addWhereClause(const IdWhereClause.any()));
  }
}

extension IsarEntryQueryWhere on QueryBuilder<IsarEntry, IsarEntry, QWhereClause> {
  QueryBuilder<IsarEntry, IsarEntry, QAfterWhereClause> idEqualTo(Id id) {
    return QueryBuilder.apply(
      this,
      (q) => q.addWhereClause(IdWhereClause.between(lower: id, upper: id)),
    );
  }
}

extension IsarEntryCollectionQuery on IsarCollection<IsarEntry> {
  QueryBuilder<IsarEntry, IsarEntry, QWhere> where() =>
  QueryBuilder(QueryBuilderInternal(collection: this));
}
