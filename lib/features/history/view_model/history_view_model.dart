import 'package:flutter/material.dart';

import '../../../core/models/song_model.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/state/player_view_model.dart';

enum HistoryKind { recent, mostPlayed }

class HistoryViewModel {
  HistoryViewModel({
    required LibraryViewModel library,
    required PlayerViewModel player,
    required this.kind,
  })  : _library = library,
        _player = player,
        songs = kind == HistoryKind.recent
            ? library.recentlyPlayed
            : library.mostPlayed;

  final LibraryViewModel _library;
  final PlayerViewModel _player;
  final HistoryKind kind;
  final List<Song> songs;

  static const _highlightedRanks = 3;

  bool get isRecent => kind == HistoryKind.recent;

  String get title => isRecent ? 'Recently played' : 'Most played';

  IconData get emptyIcon =>
      isRecent ? Icons.history_rounded : Icons.trending_up_rounded;

  // The 5-play threshold matches LibraryViewModel.mostPlayed.
  String get emptyTitle => isRecent
      ? 'Songs you play will show up here.'
      : 'Songs played more than 5 times will show up here.';

  bool isCurrent(Song song) => song == _player.current;

  bool isPlaying(Song song) => isCurrent(song) && _player.isPlaying;

  bool isFavorite(Song song) => _library.isFavorite(song);

  // Ranks only appear on Most played; null means no rank column.
  int? rankAt(int index) => isRecent ? null : index + 1;

  bool isHighlightedRank(int rank) => rank <= _highlightedRanks;

  // Plays have no stored times, so on Recently played only the song playing
  // right now gets a label; the rest show their duration instead.
  String? pillFor(Song song) {
    if (isRecent) return isCurrent(song) ? 'Now' : null;
    return '${_library.playsOf(song)}×';
  }
}
