import 'dart:io';

// What the current platform can offer, decided once at startup and provided
// app-wide so view models (and tests) don't check Platform themselves.
class PlatformCapabilities {
  const PlatformCapabilities({
    required this.supportsFolders,
    required this.hasPlaybackNotification,
  });

  // iOS songs come from the music library as asset URLs, so there are no
  // folders to browse or hide. Background playback is controlled from a
  // notification on Android and from the lock screen and Control Center on
  // iOS.
  factory PlatformCapabilities.current() => PlatformCapabilities(
        supportsFolders: !Platform.isIOS,
        hasPlaybackNotification: !Platform.isIOS,
      );

  final bool supportsFolders;
  final bool hasPlaybackNotification;
}
