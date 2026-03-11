// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'task.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TaskAdapter extends TypeAdapter<Task> {
  @override
  final int typeId = 0;

  @override
  Task read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Task(
      id: fields[0] as String,
      title: fields[1] as String,
      date: fields[2] as String,
      weekDays: (fields[3] as List).cast<bool>(),
      fromTime: fields[4] as String,
      toTime: fields[5] as String,
      tags: fields[6] as String,
      important: fields[7] as bool,
      location: fields[8] as String,
      subTask: fields[9] as String,
      beforeLoudAlert: fields[10] as bool,
      beforeMediumAlert: fields[11] as bool,
      afterLoudAlert: fields[12] as bool,
      afterMediumAlert: fields[13] as bool,
      alertBefore: fields[14] as String,
      alertAfter: fields[15] as String,
      taskCompletionDates: (fields[16] as List?)?.cast<String>() ?? [],
      taskScheduleddate: (fields[17] is String && fields[17] != null) ? fields[17] as String : '',
    );
  }


  @override
void write(BinaryWriter writer, Task obj) {
  writer
    ..writeByte(17) // Total number of fields
    ..writeByte(0)
    ..write(obj.id)
    ..writeByte(1)
    ..write(obj.title)
    ..writeByte(2)
    ..write(obj.date)
    ..writeByte(3)
    ..write(obj.weekDays)
    ..writeByte(4)
    ..write(obj.fromTime)
    ..writeByte(5)
    ..write(obj.toTime)
    ..writeByte(6)
    ..write(obj.tags)
    ..writeByte(7)
    ..write(obj.important)
    ..writeByte(8)
    ..write(obj.location)
    ..writeByte(9)
    ..write(obj.subTask)
    ..writeByte(10)
    ..write(obj.beforeLoudAlert)
    ..writeByte(11)
    ..write(obj.beforeMediumAlert)
    ..writeByte(12)
    ..write(obj.afterLoudAlert)
    ..writeByte(13)
    ..write(obj.afterMediumAlert)
    ..writeByte(14)
    ..write(obj.alertBefore)
    ..writeByte(15)
    ..write(obj.alertAfter)
    ..writeByte(16)
    ..write(obj.taskCompletionDates)
    ..writeByte(17)
    ..write(obj.taskScheduleddate);
}


  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TaskAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
