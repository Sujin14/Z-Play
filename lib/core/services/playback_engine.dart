import '../models/playback_error_model.dart';
import '../models/playback_track_model.dart';
import '../models/repeat_mode_model.dart';
import '../models/track_change_model.dart';

// The audio player as PlayerViewModel sees it, so the view model never
// touches a plugin and tests can use a fake. The engine holds a list of
// tracks and moves through it by itself; PlayerViewModel's PlaybackQueue
// decides the order and the engine's list mirrors it.
abstract class PlaybackEngine {
  // One-time setup before anything plays: the audio session for music.
  Future<void> configure();

  // Replaces the whole list and loads the track at index, positioned at
  // position, without starting playback. False when that track can't be
  // loaded (the error is also sent on errors).
  Future<bool> setQueue(
    List<PlaybackTrack> tracks, {
    required int index,
    Duration position = Duration.zero,
  });

  Future<void> play();

  Future<void> pause();

  // Stops and unloads everything; the next start needs setQueue.
  Future<void> stop();

  // Moves within the current track.
  Future<void> seek(Duration position);

  // Moves to another track in the list. False when it can't be loaded.
  Future<bool> seekToIndex(int index, {Duration position = Duration.zero});

  Future<void> setSpeed(double speed);

  Future<void> setRepeat(RepeatMode mode);

  // List edits that leave the current track playing.
  Future<void> insertTrack(int index, PlaybackTrack track);

  Future<void> removeTrack(int index);

  Future<void> moveTrack(int from, int to);

  // Keeps the current track playing and replaces everything around it:
  // before ends up ahead of it, after behind it. Used when shuffle reorders
  // the queue, and to trim the list to one track for the "end of track"
  // sleep timer (both lists empty) and restore it.
  Future<void> replaceAround({
    required List<PlaybackTrack> before,
    required List<PlaybackTrack> after,
  });

  Stream<bool> get playingChanges;

  Stream<Duration> get positionChanges;

  Stream<Duration> get durationChanges;

  Stream<TrackChange> get trackChanges;

  // The last track in the list ended (never fires while repeat is on).
  Stream<void> get queueCompleted;

  Stream<PlaybackError> get errors;

  Future<void> dispose();
}
