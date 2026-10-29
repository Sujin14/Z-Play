import 'song_model.dart';

class SongGroup {
  const SongGroup({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.songs,
  });

  final String id;
  final String title;
  final String subtitle;
  final List<Song> songs;
}
