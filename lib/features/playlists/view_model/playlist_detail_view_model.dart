import '../../../core/models/song_model.dart';
import '../../../core/models/user_playlist_model.dart';
import '../../../core/state/playlist_view_model.dart';
import '../../../core/utils/format_utils.dart';

class PlaylistDetailViewModel {
  // The name is only used until the page knows the playlist's id. After that
  // the lookup goes by id, so a rename keeps the page alive.
  PlaylistDetailViewModel(this._playlists,
      {required Object? knownId, required String openedName})
      : playlist = knownId != null
            ? _playlists.byId(knownId)
            : _playlists.named(openedName);

  final PlaylistViewModel _playlists;

  // Null once the playlist has been deleted.
  final UserPlaylist? playlist;

  List<Song> get songs => playlist!.songs;
  bool get hasSongs => songs.isNotEmpty;
  String get title => playlist!.name;
  String get subtitle => tracksLabel(songs);
  List<String> get coverSeeds => playlist!.coverSeeds;

  void removeSong(Song song) => _playlists.removeSong(playlist!.name, song);
}
