import 'dart:io';

import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/media_access_model.dart';

// Access to the device's music, behind an interface so tests can fake it.
abstract interface class MediaPermissionService {
  // Asks when needed and completes with the user's answer.
  Future<MediaAccess> request();

  Future<void> openSettings();
}

class DeviceMediaPermissionService implements MediaPermissionService {
  DeviceMediaPermissionService({OnAudioQuery? audioQuery})
      : _audioQuery = audioQuery ?? OnAudioQuery();

  final OnAudioQuery _audioQuery;

  @override
  Future<MediaAccess> request() async {
    if (Platform.isIOS) {
      // on_audio_query's iOS request returns before the user answers;
      // permission_handler waits for the answer, so the scan sees it.
      final status = await Permission.mediaLibrary.request();
      if (status.isGranted || status.isLimited) return MediaAccess.granted;
      if (status.isPermanentlyDenied || status.isRestricted) {
        return MediaAccess.permanentlyDenied;
      }
      return MediaAccess.denied;
    }
    if (Platform.isAndroid) {
      final granted = await _audioQuery.checkAndRequest(retryRequest: true);
      return granted ? MediaAccess.granted : MediaAccess.denied;
    }
    // Desktop builds read folders directly and need no permission.
    return MediaAccess.granted;
  }

  @override
  Future<void> openSettings() => openAppSettings();
}
