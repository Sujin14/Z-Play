import 'media_access_model.dart';
import 'song_model.dart';

class ScanResult {
  const ScanResult({
    required this.songs,
    required this.access,
    this.error,
  });

  final List<Song> songs;
  final MediaAccess access;
  final String? error;
}
