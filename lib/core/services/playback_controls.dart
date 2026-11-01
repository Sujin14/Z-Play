import 'package:flutter/foundation.dart';

import '../models/song_model.dart';

// What the media session (notification, lock screen, headset buttons) may
// do to playback and read from it. PlayerViewModel implements it, so the
// handler never depends on the view model's class. It notifies whenever the
// song, play state, speed or position (by a seek) changes; it never notifies
// on ordinary position ticks.
abstract interface class PlaybackControls implements Listenable {
  Song? get current;

  bool get isPlaying;

  // The current song's length, or zero while it is unknown.
  Duration get duration;

  ValueListenable<Duration> get position;

  double get speed;

  Future<void> resume();

  Future<void> pause();

  Future<void> next();

  // Restarts the song after 3 seconds; otherwise goes back one song (or
  // restarts the first song).
  Future<void> previous();

  Future<void> seek(Duration position);

  Future<void> seekBy(Duration delta);
}
