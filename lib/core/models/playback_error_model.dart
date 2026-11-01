// A track that couldn't be played. index is its position in the engine's
// list, or null when the platform didn't say.
class PlaybackError {
  const PlaybackError({required this.index, required this.message});

  final int? index;
  final String message;
}
