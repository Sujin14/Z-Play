import 'package:package_info_plus/package_info_plus.dart';

typedef PackageInfoLoader = Future<PackageInfo> Function();

// The app's version as written in pubspec.yaml, read once at startup so no
// screen has to wait for it. Tests pass their own loader instead of reading
// the platform.
class AppInfoService {
  const AppInfoService({required this.version});

  // "<version>+<buildNumber>", e.g. "1.0.0+3" for pubspec version 1.0.0+3.
  final String version;

  static Future<AppInfoService> load({
    PackageInfoLoader loader = PackageInfo.fromPlatform,
  }) async {
    final info = await loader();
    return AppInfoService(
        version: formatVersion(info.version, info.buildNumber));
  }

  // Some platforms report no build number; the version then stands alone.
  static String formatVersion(String version, String buildNumber) {
    return buildNumber.isEmpty ? version : '$version+$buildNumber';
  }
}
