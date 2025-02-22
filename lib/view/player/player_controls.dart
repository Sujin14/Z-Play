import 'package:flutter/material.dart';
import 'package:musicplayer/model/model.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';

enum RepeatMode { off, all, one }

/// MusicController handles playing, shuffling, and repeating music within a playlist.
class MusicController {
  final List<MusicFile> playlist;
  int currentIndex;
  bool isShuffling = false;
  RepeatMode repeatMode = RepeatMode.off;
  StreamSubscription? onCompleteSubscription;

  MusicController({required this.playlist, required this.currentIndex});

  /// Initializes the music player and subscribes to the player completion event.
  void init(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    musicProvider.playMusic(playlist[currentIndex]);
    _subscribeToCompletion(context, musicProvider);
  }

  /// Disposes of the subscription to the player completion event when no longer needed.
  void dispose() {
    onCompleteSubscription?.cancel();
  }

  /// Plays the next song in the playlist.
  void playNext(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    if (currentIndex < playlist.length - 1) {
      currentIndex++;
      musicProvider.playMusic(playlist[currentIndex]);
    }
  }

  /// Plays the previous song in the playlist.
  void playPrevious(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    if (currentIndex > 0) {
      currentIndex--;
      musicProvider.playMusic(playlist[currentIndex]);
    }
  }

  /// Toggles the shuffle state and shuffles the playlist if active.
  void toggleShuffle(MusicProvider musicProvider) {
    isShuffling = !isShuffling;
    if (isShuffling) {
      musicProvider.musicFiles.shuffle();
    }
  }

  /// Toggles repeat mode (off -> all -> one -> off).
  void toggleRepeatMode(BuildContext context) {
    repeatMode = getNextRepeatMode(repeatMode);
    setRepeatMode(context);
  }

  /// Sets the repeat mode for the music player and subscribes to events based on the mode.
  void setRepeatMode(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    onCompleteSubscription?.cancel();

    if (repeatMode == RepeatMode.off) {
      musicProvider.audioPlayer.setReleaseMode(ReleaseMode.stop);
    } else if (repeatMode == RepeatMode.one) {
      musicProvider.audioPlayer.setReleaseMode(ReleaseMode.loop);
    } else if (repeatMode == RepeatMode.all) {
      musicProvider.audioPlayer.setReleaseMode(ReleaseMode.stop);
      _subscribeToCompletion(context, musicProvider);
    }
  }

  /// Gets the next repeat mode in the sequence: off -> all -> one -> off.
  RepeatMode getNextRepeatMode(RepeatMode currentMode) {
    switch (currentMode) {
      case RepeatMode.off:
        return RepeatMode.all;
      case RepeatMode.all:
        return RepeatMode.one;
      case RepeatMode.one:
        return RepeatMode.off;
    }
  }

  /// Subscribes to the onPlayerComplete stream and plays the next song when the current one finishes.
  void _subscribeToCompletion(
      BuildContext context, MusicProvider musicProvider) {
    onCompleteSubscription =
        musicProvider.audioPlayer.onPlayerComplete.listen((event) {
      playNext(context);
    });
  }
}
