part of 'music_file_model.dart';

class MusicFileAdapter extends TypeAdapter<MusicFile> {
  @override
  final int typeId = 0;

  @override
  MusicFile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (var i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
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
}
