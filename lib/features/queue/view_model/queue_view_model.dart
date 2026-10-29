import '../../../core/models/song_model.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/utils/format_utils.dart';

// The screen splits the queue into the current song, what comes after it and
// what came before it. Every action still goes to the player with a position
// in the full queue, which is what keeps shuffle order correct.
class QueueViewModel {
  // Both are captured once per build, so taps act on what the screen showed.
  QueueViewModel(this.player)
      : songs = player.upNext,
        _currentIndex = player.queue.index;

  final PlayerViewModel player;
  final List<Song> songs;
  final int _currentIndex;

  bool get isEmpty => songs.isEmpty;

  String get subtitle => tracksLabel(songs, noun: 'song');

  bool get hasCurrent => songs.isNotEmpty && player.current != null;

  Song get current => player.current!;

  int get upNextStart => hasCurrent ? _currentIndex + 1 : 0;

  int get upNextCount => songs.length - upNextStart;

  // Songs before the current one; zero when nothing is current.
  int get earlierCount => hasCurrent ? _currentIndex : 0;

  int positionIn(int sectionStart, int index) => sectionStart + index;

  void jumpTo(int position) => player.jumpTo(position);

  void remove(int position) => player.removeFromQueue(position);

  void jumpToCurrent() => player.jumpTo(_currentIndex);

  void removeCurrent() => player.removeFromQueue(_currentIndex);

  // Drags happen inside one section, so both indices shift by its start.
  void reorderWithin(int sectionStart, int oldIndex, int newIndex) {
    player.reorderQueue(
        positionIn(sectionStart, oldIndex), positionIn(sectionStart, newIndex));
  }
}
