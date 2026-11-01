import 'package:flutter_test/flutter_test.dart';
import 'package:musicplayer/core/app/app_name.dart';
import 'package:musicplayer/core/services/app_info_service.dart';
import 'package:musicplayer/core/services/platform_capabilities.dart';
import 'package:musicplayer/core/utils/support_contact.dart';
import 'package:musicplayer/features/info/model/info_page_model.dart';
import 'package:package_info_plus/package_info_plus.dart';

const _android =
    PlatformCapabilities(supportsFolders: true, hasPlaybackNotification: true);
const _iphone = PlatformCapabilities(
    supportsFolders: false, hasPlaybackNotification: false);

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

    final about = InfoPage.of(InfoKind.about,
        version: service.version, capabilities: _android);

    expect(paragraphs(about, 'Version'), ['4.5.6+7']);
  });

  test('every page shows the shared support address', () {
    for (final kind in InfoKind.values) {
      final page = InfoPage.of(kind, version: '1.0.0', capabilities: _android);
      final text = page.sections
          .expand((section) => section.blocks)
          .whereType<InfoParagraph>()
          .map((paragraph) => paragraph.text)
          .join(' ');
      expect(text, contains(supportEmail), reason: kind.name);
    }
  });

  Iterable<String> allText(InfoKind kind) =>
      InfoPage.of(kind, version: '1.0.0', capabilities: _android)
          .sections
          .expand((section) => [
                for (final block in section.blocks)
                  if (block is InfoParagraph)
                    block.text
                  else if (block is InfoBullets)
                    ...block.items,
              ]);

  test('Privacy explains background playback and asks for no notifications',
      () {
    final privacy = allText(InfoKind.privacy).join(' ');
    expect(
      privacy,
      contains('Background playback: To keep your music playing when the '
          'screen is off or you switch to another app, $appName uses your '
          "device's standard media playback features."),
    );
    expect(
        privacy,
        contains('foreground service and wake lock permissions that Android '
            'grants automatically, without asking you.'));
    expect(
        privacy,
        contains(
            '$appName does not ask for permission to send notifications.'));
  });

  test('Terms describe the Android playback service', () {
    expect(
      allText(InfoKind.terms).join(' '),
      contains('On Android, $appName runs a media playback service while '
          'music is playing so playback can continue in the background; you '
          'can stop it by pausing playback and dismissing the notification.'),
    );
  });

  test('About lists background playback', () {
    expect(
      allText(InfoKind.about),
      contains('Keep music playing in the background, with notification and '
          'lock screen controls'),
    );
  });

  group('About "What you can do"', () {
    List<String> bullets(PlatformCapabilities capabilities) => InfoPage.of(
          InfoKind.about,
          version: '1.0.0',
          capabilities: capabilities,
        )
            .sections
            .singleWhere((section) => section.heading == 'What you can do')
            .blocks
            .whereType<InfoBullets>()
            .single
            .items;

    test('Android keeps folders and the notification', () {
      final android = bullets(_android);
      expect(
          android,
          contains(
              'Browse your library by songs, folders, albums and artists'));
      expect(android, contains('Hide folders you do not want in your library'));
      expect(
          android,
          contains('Keep music playing in the background, with notification '
              'and lock screen controls'));
      expect(android, hasLength(8));
    });

    test('iPhone leaves out folders and the notification', () {
      final iphone = bullets(_iphone);
      expect(
          iphone, contains('Browse your library by songs, albums and artists'));
      expect(iphone,
          isNot(contains('Hide folders you do not want in your library')));
      expect(
          iphone,
          contains('Keep music playing in the background, with lock screen '
              'controls'));
      expect(iphone.join(' '), isNot(contains('folder')));
      expect(iphone.join(' '), isNot(contains('notification')));
      expect(iphone, hasLength(7));
    });
  });

  test('only the legal pages carry a last-updated date', () {
    expect(
        InfoPage.of(InfoKind.about, version: '1', capabilities: _android)
            .lastUpdated,
        isNull);
    expect(
        InfoPage.of(InfoKind.privacy, version: '1', capabilities: _android)
            .lastUpdated,
        'Last updated: 1 November 2026');
    expect(
        InfoPage.of(InfoKind.terms, version: '1', capabilities: _android)
            .lastUpdated,
        'Last updated: 1 November 2026');
  });
}
