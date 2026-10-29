import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/state/playlist_view_model.dart';

class SplashViewModel {
  const SplashViewModel({
    required LibraryViewModel library,
    required PlaylistViewModel playlists,
    required PlayerViewModel player,
  })  : _library = library,
        _playlists = playlists,
        _player = player;

  final LibraryViewModel _library;
  final PlaylistViewModel _playlists;
  final PlayerViewModel _player;

  // Playlists resolve their songs against the library, so the library has to
  // finish loading first. isShown lets the splash stop if it was closed
  // mid-load instead of navigating from a dead screen.
  Future<void> openLibrary({required bool Function() isShown}) async {
    await _library.load();
    if (!isShown()) return;
    _playlists.load();
    await _player.prepare();
    if (!isShown()) return;
    NavigationService.pushReplacementNamed(AppRoutes.main);
  }
}
