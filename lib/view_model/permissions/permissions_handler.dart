import 'package:permission_handler/permission_handler.dart';

class PermissionsHandler {
  static Future<bool> requestStoragePermission() async {
    if (await Permission.storage.isGranted) return true;

    if (await Permission.storage.request().isGranted) return true;

    if (await Permission.manageExternalStorage.isGranted) return true;

    if (await Permission.manageExternalStorage.request().isGranted) return true;

    if (await Permission.manageExternalStorage.isPermanentlyDenied) {
      await openAppSettings();
    }

    return false;
  }
}
