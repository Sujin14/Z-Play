import 'dart:async';

import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/state/playlist_view_model.dart';

// Opens the library once the splash animation has played through and the
// library has loaded, whichever comes last. Built once by the splash screen,
// which forwards the animation's events here.
class SplashViewModel {
  SplashViewModel({
    required Future<void> Function() loadLibrary,
    required void Function() openMain,
  })  : _loadLibrary = loadLibrary,
        _openMain = openMain;

  factory SplashViewModel.forApp({
    required LibraryViewModel library,
    required PlaylistViewModel playlists,
    required PlayerViewModel player,
  }) {
    late final SplashViewModel splash;
    splash = SplashViewModel(
      // Playlists resolve their songs against the library, so the library
      // has to finish loading first.
      loadLibrary: () async {
        await library.load();
        if (splash._closed) return;
        playlists.load();
        await player.prepare();
      },
      openMain: () => NavigationService.pushReplacementNamed(AppRoutes.main),
    );
    return splash;
  }

  final Future<void> Function() _loadLibrary;
  final void Function() _openMain;

  // If the animation can't load, the app moves on after this.
  static const fallbackDelay = Duration(seconds: 1);
  // With reduced motion the last frame is shown still for this long.
  static const reducedMotionHold = Duration(milliseconds: 600);
  // The animation is about 2.9s; this only matters if it never reports
  // loading or failing, so the splash can't get stuck.
  static const maxAnimationWait = Duration(seconds: 6);

  bool _animationDone = false;
  bool _libraryReady = false;
  bool _opened = false;
  bool _closed = false;
  Timer? _animationTimer;
  Timer? _safetyTimer;

  void start() {
    _safetyTimer = Timer(maxAnimationWait, animationFinished);
    _loadLibrary().then((_) {
      _libraryReady = true;
      _openWhenReady();
    });
  }

  void animationLoaded({required bool reducedMotion}) {
    if (reducedMotion) _finishAnimationAfter(reducedMotionHold);
  }

  void animationFinished() {
    _animationDone = true;
    _openWhenReady();
  }

  void animationFailed() => _finishAnimationAfter(fallbackDelay);

  void dispose() {
    _closed = true;
    _animationTimer?.cancel();
    _safetyTimer?.cancel();
  }

  void _finishAnimationAfter(Duration delay) {
    _animationTimer ??= Timer(delay, animationFinished);
  }

  void _openWhenReady() {
    if (_closed || _opened || !_animationDone || !_libraryReady) return;
    _opened = true;
    _safetyTimer?.cancel();
    _openMain();
  }
}
