import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:on_audio_query/on_audio_query.dart';

import '../models/media_access_model.dart';
import '../models/song_model.dart';
import '../models/scan_result_model.dart';

class SongScanner {
  SongScanner({OnAudioQuery? audioQuery})
      : _audioQuery = audioQuery ?? OnAudioQuery();

  final OnAudioQuery _audioQuery;

  static const _extensions = {
    '.mp3',
    '.wav',
    '.aac',
    '.ogg',
    '.flac',
    '.m4a',
    '.opus',
    '.wma',
    '.alac',
    '.aiff',
    '.aif',
    '.amr',
  };

  // Android's MediaStore and the iOS music library are both read through
  // on_audio_query; other platforms only have the folder walk.
  static bool get _hasMediaLibrary => Platform.isAndroid || Platform.isIOS;

  // access is the answer to the media permission, asked for before the scan.
  Future<ScanResult> scan({required MediaAccess access}) async {
    final songs = <String, Song>{};
    final granted = access == MediaAccess.granted;
    String? error;

    if (_hasMediaLibrary && granted) {
      try {
        final indexed = await _audioQuery.querySongs(
          uriType: UriType.EXTERNAL,
          ignoreCase: true,
        );
        for (final model in indexed) {
          final song = _fromMediaStore(model);
          if (song == null) continue;
          songs[song.path] = song;
        }
      } catch (exception, stackTrace) {
        debugPrint('MediaStore scan failed: $exception\n$stackTrace');
        error = 'The system music index could not be read.';
      }
    }

    try {
      final roots = await _volumeRoots();
      for (final root in roots) {
        await _walk(root, songs);
      }
    } catch (exception, stackTrace) {
      debugPrint('Storage walk failed: $exception\n$stackTrace');
      error ??= 'Some storage volumes could not be scanned.';
    }

    if (_hasMediaLibrary && !granted && songs.isEmpty) {
      error = 'Allow audio access to scan the music on this device.';
    }

    final library = songs.values.toList()
      ..sort((a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()));
    return ScanResult(
      songs: library,
      access: songs.isNotEmpty ? MediaAccess.granted : access,
      error: library.isEmpty ? error : null,
    );
  }

  // Reads the raw map: on iOS the path and title are null for cloud or DRM
  // items, and the typed getters would throw and fail the whole scan. Those
  // items have nothing playable on the device, so they are skipped.
  Song? _fromMediaStore(SongModel model) {
    final info = model.getMap;
    final filePath = (info['_data'] as String?)?.trim() ?? '';
    if (filePath.isEmpty) return null;
    final title = _label(info['title'] as String?, _fileName(filePath));
    return Song(
      path: filePath,
      title: title,
      artist: _label(model.artist, 'Unknown artist'),
      album: _label(model.album, 'Unknown album'),
      genre: _label(model.genre, ''),
      durationMs: model.duration ?? 0,
      dateAddedMs: _toMillis(model.dateAdded),
      isSystemSound: model.isRingtone == true ||
          model.isAlarm == true ||
          model.isNotification == true ||
          _pathIsSystemSound(filePath),
    );
  }

  Future<List<Directory>> _volumeRoots() async {
    // An iOS app only sees its own sandbox, which holds no music; the library
    // query is the only source there.
    if (Platform.isIOS) return const [];
    if (Platform.isAndroid) {
      final storage = Directory('/storage');
      if (!await storage.exists()) return const [];
      final roots = <Directory>[];
      await for (final entity in storage.list(followLinks: false)) {
        if (entity is! Directory) continue;
        final name = entity.path.split('/').last;
        if (name == 'self') continue;
        if (name == 'emulated') {
          final primary = Directory('${entity.path}/0');
          if (await primary.exists()) roots.add(primary);
          continue;
        }
        roots.add(entity);
      }
      return roots;
    }

    final home =
        Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'];
    if (home == null || home.isEmpty) return const [];
    final separator = Platform.isWindows ? '\\' : '/';
    final candidates = [
      Directory('$home${separator}Music'),
      Directory('$home${separator}Downloads'),
      Directory('$home${separator}Documents'),
    ];
    final roots = <Directory>[];
    for (final directory in candidates) {
      if (await directory.exists()) roots.add(directory);
    }
    return roots;
  }

  Future<void> _walk(Directory directory, Map<String, Song> songs) async {
    if (_shouldSkip(directory.path) || !await directory.exists()) return;
    try {
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is Directory) {
          await _walk(entity, songs);
          continue;
        }
        if (entity is! File ||
            !_isAudio(entity.path) ||
            songs.containsKey(entity.path)) {
          continue;
        }
        songs[entity.path] = Song(
          path: entity.path,
          title: _fileName(entity.path),
          isSystemSound: _pathIsSystemSound(entity.path),
          dateAddedMs: await _modifiedAt(entity),
        );
      }
    } catch (exception) {
      debugPrint('Skipped ${directory.path}: $exception');
    }
  }

  Future<int> _modifiedAt(File file) async {
    try {
      return (await file.lastModified()).millisecondsSinceEpoch;
    } catch (_) {
      return 0;
    }
  }

  bool _shouldSkip(String path) {
    final normalized = path.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('/android/data') ||
        normalized.contains('/android/obb') ||
        normalized.contains('/.');
  }

  bool _isAudio(String path) {
    final lower = path.toLowerCase();
    return _extensions.any(lower.endsWith);
  }

  bool _pathIsSystemSound(String path) {
    final normalized = path.replaceAll('\\', '/').toLowerCase();
    return normalized.contains('/ringtones/') ||
        normalized.contains('/alarms/') ||
        normalized.contains('/notifications/');
  }

  String _fileName(String path) {
    final normalized = path.replaceAll('\\', '/');
    final name = normalized.split('/').last;
    final dot = name.lastIndexOf('.');
    if (dot <= 0) return name;
    return name.substring(0, dot);
  }

  String _label(String? value, String fallback) {
    final text = value?.trim() ?? '';
    if (text.isEmpty || text.toLowerCase() == '<unknown>') return fallback;
    return text;
  }

  int _toMillis(int? value) {
    if (value == null || value <= 0) return 0;
    if (value < 100000000000) return value * 1000;
    return value;
  }
}
