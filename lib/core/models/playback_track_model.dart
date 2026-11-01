// One entry in the engine's list. isUrl marks an iOS ipod-library:// asset
// URL rather than a file path.
class PlaybackTrack {
  const PlaybackTrack({required this.path, required this.isUrl});

  final String path;
  final bool isUrl;
}
