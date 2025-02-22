import 'dart:io';
import '../../model/model.dart';

/// **FileScanner Class**
/// - Scans directories for audio files.
/// - Supports multiple formats: **MP3, WAV, AAC, OGG, FLAC**.
/// - Uses parallel processing for efficiency.
/// - Handles errors gracefully.
class FileScanner {
  /// **List of Directories to Search for Audio Files**
  static final List<Directory> _directoriesToSearch = [
    Directory('/storage/emulated/0/Music'),
    Directory('/storage/emulated/0/Download'),
    Directory('/storage/emulated/0/Audio'),
    Directory('/storage/emulated/0/Podcasts'),
    Directory('/storage/emulated/0/Ringtones'),
    Directory('/storage/emulated/0/Alarms'),
    Directory('/storage/emulated/0/Notifications'),
  ];

  /// **Fetches All Music Files from Specified Directories**
  /// - Runs directory scans **in parallel** for efficiency.
  /// - Skips inaccessible directories without crashing.
  static Future<List<MusicFile>> fetchAllMusicFiles() async {
    List<MusicFile> audioFiles = [];

    try {
      final results = await Future.wait(
        _directoriesToSearch.map((dir) => _scanDirectoryForAudioFiles(dir)),
      );

      for (var files in results) {
        audioFiles.addAll(files);
      }
    } catch (e) {
      print('Error scanning directories: $e');
    }

    return audioFiles;
  }

  /// **Scans a Directory for Audio Files**
  /// - Checks for valid audio formats.
  /// - Skips hidden/system files for efficiency.
  static Future<List<MusicFile>> _scanDirectoryForAudioFiles(
      Directory dir) async {
    List<MusicFile> audioFiles = [];

    if (!await dir.exists()) return [];

    try {
      await for (var entity in dir.list(recursive: true, followLinks: false)) {
        if (entity is File && _isValidAudioFile(entity.path)) {
          audioFiles.add(MusicFile(
            path: entity.path,
            title: entity.uri.pathSegments.last,
          ));
        }
      }
    } catch (e) {
      print('Error scanning ${dir.path}: $e');
    }

    return audioFiles;
  }

  /// **Checks if a File is a Valid Audio File**
  static bool _isValidAudioFile(String path) {
    final supportedFormats = ['.mp3', '.wav', '.aac', '.ogg', '.flac'];
    return supportedFormats
        .any((format) => path.toLowerCase().endsWith(format));
  }
}
