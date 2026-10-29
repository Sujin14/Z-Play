class PlaybackSnapshot {
  const PlaybackSnapshot({
    required this.paths,
    required this.index,
    required this.positionMs,
    required this.speed,
  });

  final List<String> paths;
  final int index;
  final int positionMs;
  final double speed;

  static const empty = PlaybackSnapshot(
    paths: [],
    index: 0,
    positionMs: 0,
    speed: 1,
  );
}
