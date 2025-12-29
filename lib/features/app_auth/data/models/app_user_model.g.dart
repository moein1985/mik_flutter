// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_user_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AppUserModelAdapter extends TypeAdapter<AppUserModel> {
  @override
  final int typeId = 0;

  @override
  AppUserModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppUserModel(
      id: fields[0] as String,
      username: fields[1] as String,
      passwordHash: fields[2] as String,
      biometricEnabled: fields[3] as bool,
      createdAt: fields[4] as DateTime,
      isDefault: fields[5] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, AppUserModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.username)
      ..writeByte(2)
      ..write(obj.passwordHash)
      ..writeByte(3)
      ..write(obj.biometricEnabled)
      ..writeByte(4)
      ..write(obj.createdAt)
      ..writeByte(5)
      ..write(obj.isDefault);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppUserModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
