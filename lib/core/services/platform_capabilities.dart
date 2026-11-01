import 'dart:io';

// What the current platform can offer, decided once at startup and provided
// app-wide so view models (and tests) don't check Platform themselves.
class PlatformCapabilities {
  const PlatformCapabilities({required this.supportsFolders});

  // iOS songs come from the music library as asset URLs, so there are no
  // folders to browse or hide.
  factory PlatformCapabilities.current() =>
      PlatformCapabilities(supportsFolders: !Platform.isIOS);

  final bool supportsFolders;
}
