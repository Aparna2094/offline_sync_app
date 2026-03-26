// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'queue_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class QueueItemAdapter extends TypeAdapter<QueueItem> {
  @override
  final int typeId = 1;

  @override
  QueueItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return QueueItem(
      id: fields[0] as String,
      action: fields[1] as String,
      data: (fields[2] as Map).cast<String, dynamic>(),
      retryCount: fields[3] as int,
      createdAt: fields[4] as int,
    );
  }

  @override
  void write(BinaryWriter writer, QueueItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.action)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.retryCount)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
