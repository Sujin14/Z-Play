// GENERATED CODE - DO NOT MODIFY BY HAND

part of '../models/music_file.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MusicFileAdapter extends TypeAdapter<MusicFile> {
  @override
  final int typeId = 0;

  @override
  MusicFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MusicFile(
      path: fields[0] as String,
      title: fields[1] as String,
    );
  }

  @override
  void write(BinaryWriter writer, MusicFile obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.path)
      ..writeByte(1)
      ..write(obj.title);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MusicFileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
