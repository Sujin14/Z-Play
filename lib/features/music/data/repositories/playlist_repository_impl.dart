import 'package:musicplayer/core/storage/hive_storage.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/music_file_entity.dart';
import '../../domain/repositories/playlist_repository.dart';
import '../models/playlist.dart';
import '../models/music_file.dart';

class PlaylistRepositoryImpl implements PlaylistRepository {
  final HiveStorage hiveStorage;

  PlaylistRepositoryImpl({required this.hiveStorage});

  @override
  Future<void> createPlaylist(PlaylistEntity playlist) async {
    await HiveStorage.createPlaylist(playlist.name);
  }

  @override
  Future<void> addSongToPlaylist(
      PlaylistEntity playlist, MusicFileEntity song) async {
    final hivePlaylist = HiveStorage.getPlaylists().firstWhere(
      (p) => p.name == playlist.name,
      orElse: () => Playlist(name: playlist.name, songs: []),
    );
    await HiveStorage.addSongToPlaylist(
      hivePlaylist,
      MusicFile(path: song.path, title: song.title),
    );
  }

  @override
  Future<void> removeSongFromPlaylist(
      PlaylistEntity playlist, MusicFileEntity song) async {
    final hivePlaylist = HiveStorage.getPlaylists().firstWhere(
      (p) => p.name == playlist.name,
      orElse: () => Playlist(name: playlist.name, songs: []),
    );
    await HiveStorage.removeSongFromPlaylist(
      hivePlaylist,
      MusicFile(path: song.path, title: song.title),
    );
  }

  @override
  Future<void> deletePlaylist(PlaylistEntity playlist) async {
    final hivePlaylist = HiveStorage.getPlaylists().firstWhere(
      (p) => p.name == playlist.name,
      orElse: () => Playlist(name: playlist.name, songs: []),
    );
    await HiveStorage.deletePlaylist(hivePlaylist);
  }

  @override
  Future<List<PlaylistEntity>> getPlaylists() async {
    return HiveStorage.getPlaylists()
        .map((p) => PlaylistEntity(
              name: p.name,
              songs: p.songs
                  .map((s) => MusicFileEntity(path: s.path, title: s.title))
                  .toList(),
            ))
        .toList();
  }
}