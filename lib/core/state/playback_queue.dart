import '../models/song_model.dart';
import '../models/repeat_mode_model.dart';

class PlaybackQueue {
  PlaybackQueue({
    required List<Song> songs,
    int startIndex = 0,
  })  : _base = List<Song>.of(songs),
        _order = List<Song>.of(songs) {
    if (_order.isEmpty) {
      index = 0;
      return;
    }
    index = startIndex.clamp(0, _order.length - 1);
  }

  List<Song> _base;
  List<Song> _order;
  int index = 0;
  bool shuffling = false;

  List<Song> get songs => List.unmodifiable(_order);

  Song? get current => _order.isEmpty ? null : _order[index];

  bool get hasNext => index < _order.length - 1;

  void shuffleOn() {
    final currentSong = current;
    final rest = <Song>[
      for (var i = 0; i < _order.length; i++)
        if (i != index) _order[i],
    ]..shuffle();
    _order = [
      if (currentSong != null) currentSong,
      ...rest,
    ];
    index = 0;
    shuffling = true;
  }

  void shuffleOff() {
    final currentPath = current?.path;
    _order = List<Song>.of(_base);
    index = _indexOf(currentPath, _order);
    shuffling = false;
  }

  bool skipNext(RepeatMode repeat) {
    if (_order.isEmpty) return false;
    if (index < _order.length - 1) {
      index++;
      return true;
    }
    if (repeat == RepeatMode.all) {
      index = 0;
      return true;
    }
    return false;
  }

  bool skipPrevious() {
    if (index <= 0) return false;
    index--;
    return true;
  }

  void jumpTo(int nextIndex) {
    if (nextIndex < 0 || nextIndex >= _order.length) return;
    index = nextIndex;
  }

  void playNext(Song song) {
    _removePath(song.path);
    final insertAt = _order.isEmpty ? 0 : index + 1;
    _order.insert(insertAt.clamp(0, _order.length), song);
    _insertInBase(song);
  }

  void addToEnd(Song song) {
    if (_order.any((item) => item.path == song.path)) return;
    _order.add(song);
    if (_base.every((item) => item.path != song.path)) {
      _base.add(song);
    }
  }

  void removeAt(int orderIndex) {
    if (orderIndex < 0 || orderIndex >= _order.length) return;
    final removed = _order.removeAt(orderIndex);
    _base.removeWhere((song) => song.path == removed.path);
    if (_order.isEmpty) {
      index = 0;
      return;
    }
    if (orderIndex < index) {
      index--;
    } else if (orderIndex == index && index >= _order.length) {
      index = _order.length - 1;
    }
  }

  void reorder(int oldIndex, int newIndex) {
    if (oldIndex < 0 || oldIndex >= _order.length) return;
    newIndex = newIndex.clamp(0, _order.length - 1);
    final song = _order.removeAt(oldIndex);
    _order.insert(newIndex, song);
    if (index == oldIndex) {
      index = newIndex;
    } else if (oldIndex < index && newIndex >= index) {
      index--;
    } else if (oldIndex > index && newIndex <= index) {
      index++;
    }
    if (!shuffling) {
      _base = List<Song>.of(_order);
    }
  }

  void _removePath(String path) {
    final orderIndex = _order.indexWhere((song) => song.path == path);
    if (orderIndex >= 0) {
      _order.removeAt(orderIndex);
      if (orderIndex < index) index--;
      if (index >= _order.length) {
        index = _order.isEmpty ? 0 : _order.length - 1;
      }
    }
    _base.removeWhere((song) => song.path == path);
  }

  void _insertInBase(Song song) {
    final currentPath = current?.path;
    final baseIndex = _base.indexWhere((item) => item.path == currentPath);
    final insertAt = baseIndex < 0 ? _base.length : baseIndex + 1;
    _base.insert(insertAt, song);
  }

  int _indexOf(String? path, List<Song> songs) {
    if (path == null || songs.isEmpty) return 0;
    final found = songs.indexWhere((song) => song.path == path);
    return found < 0 ? 0 : found;
  }
}
