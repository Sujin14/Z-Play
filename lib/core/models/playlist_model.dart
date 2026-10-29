import 'package:hive/hive.dart';

import 'music_file_model.dart';

part 'playlist_model.g.dart';

@HiveType(typeId: 1)
class Playlist extends HiveObject {
  Playlist({required this.name, required this.songs});

  @HiveField(0)
  String name;

  @HiveField(1)
  List<MusicFile> songs;
}
