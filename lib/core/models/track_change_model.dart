// The engine moved to the track at index. automatic is true when the
// platform got there by itself (the previous track ended, or repeat
// restarted it); false when a call from the app moved it.
class TrackChange {
  const TrackChange({required this.index, required this.automatic});

  final int index;
  final bool automatic;
}
