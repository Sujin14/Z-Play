import 'package:flutter/foundation.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/music_file_entity.dart';
import '../../domain/usecases/create_playlist.dart';
import '../../domain/usecases/manage_playlist.dart';
import '../../domain/usecases/get_playlists.dart';

class PlaylistViewModel extends ChangeNotifier {
  final CreatePlaylist createPlaylist;
  final ManagePlaylist managePlaylist;
  final GetPlaylists getPlaylists;

  bool isLoading = true;
  List<PlaylistEntity> playlists = [];

  PlaylistViewModel({
    required this.createPlaylist,
    required this.managePlaylist,
    required this.getPlaylists,
  }) {
    loadPlaylists();
  }

  Future<void> loadPlaylists() async {
    isLoading = true;
    notifyListeners();
    playlists = await getPlaylists();
    isLoading = false;
    notifyListeners();
  }

  Future<void> createNewPlaylist(PlaylistEntity playlist) async {
    await createPlaylist(playlist);
    await loadPlaylists();
  }

  Future<void> addSongToPlaylist(
      PlaylistEntity playlist, MusicFileEntity song) async {
    await managePlaylist.addSongToPlaylist(playlist, song);
    await loadPlaylists();
  }

  Future<void> removeSongFromPlaylist(
      PlaylistEntity playlist, MusicFileEntity song) async {
    await managePlaylist.removeSongFromPlaylist(playlist, song);
    await loadPlaylists();
  }

  Future<void> deletePlaylist(PlaylistEntity playlist) async {
    await managePlaylist.deletePlaylist(playlist);
    await loadPlaylists();
  }

  Future<void> editPlaylistName(PlaylistEntity playlist, String newName) async {
    final updatedPlaylist =
        PlaylistEntity(name: newName, songs: playlist.songs);

    await deletePlaylist(playlist);
    await createNewPlaylist(updatedPlaylist);
  }
}