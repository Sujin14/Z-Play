import 'package:audio_service/audio_service.dart';

import 'playback_controls.dart';

// The media session behind the Android notification, the lock screen and
// headset or Bluetooth buttons. It forwards their actions to
// PlaybackControls and publishes the current song and play state. The
// position is published only when it jumps (play, pause, seek, new song,
// speed); the system moves the progress bar on by itself from the last
// position and the speed.
class MediaSessionHandler extends BaseAudioHandler {
  MediaSessionHandler();

  static const channelId = 'com.sujin.musicplayer.playback';
  static const channelName = 'Playback';
  static const skipInterval = Duration(seconds: 10);

  // No close action: swiping the paused notification away stops the
  // service, and the queue stays saved for the next launch.
  static const config = AudioServiceConfig(
    androidNotificationChannelId: channelId,
    androidNotificationChannelName: channelName,
    androidNotificationIcon: 'drawable/ic_notification',
    androidNotificationOngoing: false,
    androidStopForegroundOnPause: true,
    androidResumeOnClick: true,
    fastForwardInterval: skipInterval,
    rewindInterval: skipInterval,
  );

  static const _controls = [
    MediaControl.rewind,
    MediaControl.skipToPrevious,
    MediaControl.play,
    MediaControl.skipToNext,
    MediaControl.fastForward,
  ];
  // previous, play/pause, next in the collapsed notification.
  static const _compactIndices = [1, 2, 3];
  static const _playPauseIndex = 2;
  static const _systemActions = {
    MediaAction.seek,
    MediaAction.skipToNext,
    MediaAction.skipToPrevious,
    MediaAction.fastForward,
    MediaAction.rewind,
  };

  PlaybackControls? _player;
  // Set after the notification is swiped away; the session stays idle
  // until playback starts again.
  bool _dismissed = false;

  void attach(PlaybackControls player) {
    _player?.removeListener(_publish);
    _player = player;
    player.addListener(_publish);
    _publish();
  }

  @override
  Future<void> play() async => _player?.resume();

  @override
  Future<void> pause() async => _player?.pause();

  @override
  Future<void> skipToNext() async => _player?.next();

  @override
  Future<void> skipToPrevious() async => _player?.previous();

  @override
  Future<void> seek(Duration position) async => _player?.seek(position);

  @override
  Future<void> fastForward() async => _player?.seekBy(skipInterval);

  @override
  Future<void> rewind() async => _player?.seekBy(-skipInterval);

  // Called when the notification is swiped away. Pauses instead of
  // PlayerViewModel.stop(), which would clear the saved queue.
  @override
  Future<void> stop() async {
    _dismissed = true;
    await _player?.pause();
    playbackState
        .add(PlaybackState(processingState: AudioProcessingState.idle));
  }

  void _publish() {
    final player = _player;
    final song = player?.current;
    if (player == null || song == null) {
      _dismissed = false;
      if (mediaItem.value != null) mediaItem.add(null);
      playbackState
          .add(PlaybackState(processingState: AudioProcessingState.idle));
      return;
    }
    if (player.isPlaying) _dismissed = false;
    if (_dismissed) return;

    final length = player.duration > Duration.zero ? player.duration : null;
    final item = mediaItem.value;
    if (item == null ||
        item.id != song.path ||
        item.title != song.title ||
        item.artist != song.artist ||
        item.album != song.album ||
        item.duration != length) {
      mediaItem.add(MediaItem(
        id: song.path,
        title: song.title,
        artist: song.artist,
        album: song.album,
        duration: length,
      ));
    }

    final controls = List.of(_controls);
    controls[_playPauseIndex] =
        player.isPlaying ? MediaControl.pause : MediaControl.play;
    playbackState.add(PlaybackState(
      processingState: AudioProcessingState.ready,
      playing: player.isPlaying,
      controls: controls,
      androidCompactActionIndices: _compactIndices,
      systemActions: _systemActions,
      updatePosition: player.position.value,
      speed: player.speed,
    ));
  }
}
