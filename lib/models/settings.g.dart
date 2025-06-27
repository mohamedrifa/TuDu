// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SettingsAdapter extends TypeAdapter<AppSettings>  {
  @override
  final int typeId = 1;

  @override
   read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      mediumAlertTone: fields[0] as String,
      loudAlertTone: fields[1] as String,
      batteryUnrestricted: fields[2] as bool? ?? false,
    );
  }


  @override
void write(BinaryWriter writer, AppSettings obj) {
  writer
    ..writeByte(3) // Total number of fields
    ..writeByte(0)
    ..write(obj.mediumAlertTone)
    ..writeByte(1)
    ..write(obj.loudAlertTone)
    ..writeByte(2)
    ..write(obj.batteryUnrestricted);
}


  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
