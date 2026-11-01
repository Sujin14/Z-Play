import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/services/app_info_service.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  Future<PackageInfo> fakeInfo(String version, String buildNumber) async {
    return PackageInfo(
      appName: 'Z Play',
      packageName: 'com.example.zplay',
      version: version,
      buildNumber: buildNumber,
    );
  }

  test('formats the pubspec version as version+build', () async {
    final service =
        await AppInfoService.load(loader: () => fakeInfo('1.0.0', '3'));

    expect(service.version, '1.0.0+3');
  });

  test('leaves out the build number when the platform reports none', () async {
    final service =
        await AppInfoService.load(loader: () => fakeInfo('2.1.0', ''));

    expect(service.version, '2.1.0');
  });
}
