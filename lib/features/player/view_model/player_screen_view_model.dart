import 'dart:math' as math;

import 'package:flutter/rendering.dart' show BoxConstraints;

import '../../../core/models/repeat_mode_model.dart';
import '../../../core/models/song_model.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/format_utils.dart';

class PlayerScreenViewModel {
  const PlayerScreenViewModel(this.player);

  final PlayerViewModel player;

  static const speeds = [0.75, 1.0, 1.25, 1.5, 2.0];
  static const sleepMinutes = [15, 30, 45, 60];

  // Everything except the cover takes roughly this much height; the cover
  // gets what is left, between 200 and 300px.
  static const double _fixedHeight = 470;
  static const double _errorHeight = 24;
  static const double _minCover = 200;
  static const double _maxCover = 300;

  Song? get song => player.current;

  String? get error => player.error;

  // Null when the album is unknown, which hides the second top-bar line.
  String? get fromLine {
    final album = song?.album;
    if (album == null || album.isEmpty || album == 'Unknown album') return null;
    return 'From $album';
  }

  double coverSize(BoxConstraints constraints) {
    final fixed = _fixedHeight + (error != null ? _errorHeight : 0);
    return math.max(
      _minCover,
      math.min(
        math.min(_maxCover, constraints.maxWidth - AppSpacing.screen * 2),
        constraints.maxHeight - fixed,
      ),
    );
  }

  String get shuffleTooltip => player.shuffling ? 'Shuffle on' : 'Shuffle off';

  bool get repeatActive => player.repeatMode != RepeatMode.off;

  String get repeatTooltip => switch (player.repeatMode) {
        RepeatMode.off => 'Repeat off',
        RepeatMode.all => 'Repeat all',
        RepeatMode.one => 'Repeat one',
      };

  String get speedLabel => formatSpeed(player.speed);

  bool isCurrentSpeed(double rate) => player.speed == rate;

  // A timed sleep or "end of track" both count as an active timer.
  bool get isSleepActive =>
      player.sleepUntil != null || player.stopAfterCurrent;

  bool isSleepChoice(int minutes) =>
      player.sleepDuration == Duration(minutes: minutes);

  // No remaining time means the timer is set to end of track.
  bool get isEndOfTrack => player.sleepRemaining == null;

  String get sleepLabel {
    final remaining = player.sleepRemaining;
    return remaining == null ? 'End of track' : formatCountdown(remaining);
  }

  String get sleepCaption =>
      isEndOfTrack ? 'Music stops after this song' : 'left on your timer';

  // How much of the timer is left, for the ring; full for end of track.
  double get sleepProgress {
    final remaining = player.sleepRemaining;
    final total = player.sleepDuration;
    if (remaining == null || total == null || total.inMilliseconds <= 0) {
      return 1.0;
    }
    return (remaining.inMilliseconds / total.inMilliseconds).clamp(0.0, 1.0);
  }

  Song? get nextSong => player.nextSong;

  String nextLabel(Song next) => '${next.title} · ${next.artist}';
}
