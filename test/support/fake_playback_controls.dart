import 'package:flutter/foundation.dart';
import 'package:musicplayer/core/models/song_model.dart';
import 'package:musicplayer/core/services/playback_controls.dart';

// Records every call as a short string and lets a test set the state the
// media session reads, then notify like PlayerViewModel does.
class FakePlaybackControls extends ChangeNotifier implements PlaybackControls {
  final calls = <String>[];

  @override
  Song? current;

  @override
  bool isPlaying = false;

  @override
  Duration duration = Duration.zero;

  @override
  final ValueNotifier<Duration> position = ValueNotifier(Duration.zero);

  @override
  double speed = 1;

  void changed() => notifyListeners();

  @override
  Future<void> resume() async => calls.add('resume');

  @override
  Future<void> pause() async => calls.add('pause');

  @override
  Future<void> next() async => calls.add('next');

  @override
  Future<void> previous() async => calls.add('previous');

  @override
  Future<void> seek(Duration position) async =>
      calls.add('seek:${position.inSeconds}');

  @override
  Future<void> seekBy(Duration delta) async =>
      calls.add('seekBy:${delta.inSeconds}');
}
