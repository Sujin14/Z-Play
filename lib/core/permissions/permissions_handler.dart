import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  static Future<bool> requestStoragePermission() async {
    // Ask normal storage permission first
    PermissionStatus status = await Permission.storage.request();

    if (status.isGranted) return true;

    // For Android 11+
    if (!await Permission.manageExternalStorage.isGranted) {
      final manageStatus =
          await Permission.manageExternalStorage.request();

      if (manageStatus.isGranted) return true;
    }

    // If permanently denied
    if (status.isPermanentlyDenied ||
        await Permission.manageExternalStorage.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}