import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/models/song_model.dart';
import 'package:musicplayer/core/state/playback_queue.dart';
import 'package:musicplayer/core/models/repeat_mode_model.dart';

void main() {
  const first = Song(path: '/music/a.mp3', title: 'A');
  const second = Song(path: '/music/b.mp3', title: 'B');
  const third = Song(path: '/music/c.mp3', title: 'C');

  test('songs with the same path are equal', () {
    expect(const Song(path: '/a.mp3', title: 'One'),
        const Song(path: '/a.mp3', title: 'Two'));
  });

  test('shuffle keeps the current song and can restore the original order', () {
    final queue =
        PlaybackQueue(songs: const [first, second, third], startIndex: 1);
    queue.shuffleOn();
    expect(queue.current, second);
    expect(queue.songs, hasLength(3));
    queue.shuffleOff();
    expect(queue.songs.map((song) => song.path).toList(), [
      first.path,
      second.path,
      third.path,
    ]);
    expect(queue.current, second);
  });

  test('repeat all wraps and repeat off stops at the end', () {
    final queue = PlaybackQueue(songs: const [first, second], startIndex: 1);
    expect(queue.skipNext(RepeatMode.off), isFalse);
    expect(queue.skipNext(RepeatMode.all), isTrue);
    expect(queue.current, first);
  });

  test('play next inserts after the current song without duplicating it', () {
    final queue = PlaybackQueue(songs: const [first, second], startIndex: 0);
    queue.playNext(third);
    queue.playNext(third);
    expect(queue.songs.map((song) => song.title).toList(), ['A', 'C', 'B']);
  });
}
