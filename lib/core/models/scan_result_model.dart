import 'song_model.dart';

class ScanResult {
  const ScanResult({
    required this.songs,
    required this.permissionGranted,
    this.error,
  });

  final List<Song> songs;
  final bool permissionGranted;
  final String? error;
}
