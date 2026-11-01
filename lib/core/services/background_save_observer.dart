import 'package:flutter/widgets.dart';

// Saves playback the moment the app leaves the screen, without waiting for
// the usual short delay: the system may stop the process soon after.
class BackgroundSaveObserver with WidgetsBindingObserver {
  BackgroundSaveObserver(this._save);

  final Future<void> Function() _save;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _save();
      case AppLifecycleState.resumed:
      case AppLifecycleState.inactive:
        break;
    }
  }
}
