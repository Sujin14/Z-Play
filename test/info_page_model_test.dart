import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/services/app_info_service.dart';
import 'package:musicplayer/core/utils/support_contact.dart';
import 'package:musicplayer/features/info/model/info_page_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() {
  Iterable<String> paragraphs(InfoPage page, String heading) => page.sections
      .where((section) => section.heading == heading)
      .expand((section) => section.blocks)
      .whereType<InfoParagraph>()
      .map((paragraph) => paragraph.text);

  test('the About page shows the version from the app info service', () async {
    final service = await AppInfoService.load(
      loader: () async => PackageInfo(
        appName: 'Z Play',
        packageName: 'com.example.zplay',
        version: '4.5.6',
        buildNumber: '7',
      ),
    );

    final about = InfoPage.of(InfoKind.about, version: service.version);

    expect(paragraphs(about, 'Version'), ['4.5.6+7']);
  });

  test('every page shows the shared support address', () {
    for (final kind in InfoKind.values) {
      final page = InfoPage.of(kind, version: '1.0.0');
      final text = page.sections
          .expand((section) => section.blocks)
          .whereType<InfoParagraph>()
          .map((paragraph) => paragraph.text)
          .join(' ');
      expect(text, contains(supportEmail), reason: kind.name);
    }
  });

  test('only the legal pages carry a last-updated date', () {
    expect(InfoPage.of(InfoKind.about, version: '1').lastUpdated, isNull);
    expect(InfoPage.of(InfoKind.privacy, version: '1').lastUpdated,
        'Last updated: 1 November 2026');
    expect(InfoPage.of(InfoKind.terms, version: '1').lastUpdated,
        'Last updated: 1 November 2026');
  });
}
