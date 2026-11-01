import 'repeat_mode_model.dart';

class PlaybackSnapshot {
  const PlaybackSnapshot({
    required this.paths,
    required this.index,
    required this.positionMs,
    required this.speed,
    this.originalPaths = const [],
    this.shuffling = false,
    this.repeat = RepeatMode.off,
  });

  // The queue in playing order; index points into it.
  final List<String> paths;
  final int index;
  final int positionMs;
  final double speed;
  // The order before shuffling, so turning shuffle off after a restart
  // brings it back. Empty when it is the same as paths.
  final List<String> originalPaths;
  final bool shuffling;
  final RepeatMode repeat;

  static const empty = PlaybackSnapshot(
    paths: [],
    index: 0,
    positionMs: 0,
    speed: 1,
  );
}
