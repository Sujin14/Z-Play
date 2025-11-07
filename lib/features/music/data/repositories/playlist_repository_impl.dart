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

  /// ✅ Rename a playlist without losing its songs
  @override
  Future<void> renamePlaylist(PlaylistEntity playlist, String newName) async {
    // Get all existing playlists
    final playlists = HiveStorage.getPlaylists();

    // Find the one to rename
    final index = playlists.indexWhere((p) => p.name == playlist.name);
    if (index == -1) return;

    final updatedPlaylist = Playlist(
      name: newName,
      songs: playlists[index].songs, // keep existing songs intact
    );

    // Delete the old playlist and save the renamed one
    await HiveStorage.deletePlaylist(playlists[index]);
    await HiveStorage.savePlaylist(updatedPlaylist);
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
        .map(
          (p) => PlaylistEntity(
            name: p.name,
            songs: p.songs
                .map(
                  (s) => MusicFileEntity(path: s.path, title: s.title),
                )
                .toList(),
          ),
        )
        .toList();
  }
}
