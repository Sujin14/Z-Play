import '../../../core/models/user_playlist_model.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/state/playlist_view_model.dart';
import '../../../core/utils/format_utils.dart';

class PlaylistsViewModel {
  const PlaylistsViewModel(this._playlists);

  final PlaylistViewModel _playlists;

  List<UserPlaylist> get playlists => _playlists.playlists;

  bool get isEmpty => playlists.isEmpty;

  String subtitleFor(UserPlaylist playlist) => tracksLabel(playlist.songs);

  // The detail route takes the name; the detail page then switches to the id
  // so a later rename keeps it open.
  void open(UserPlaylist playlist) {
    NavigationService.pushNamed(AppRoutes.playlist, arguments: playlist.name);
  }

  String deleteMessage(String name) =>
      'Delete "$name"? The songs stay on your device.';

  // confirm shows the dialog; nothing is deleted unless it resolves to true.
  Future<void> delete(String name,
      {required Future<bool> Function() confirm}) async {
    final confirmed = await confirm();
    if (confirmed) {
      await _playlists.delete(name);
    }
  }
}
