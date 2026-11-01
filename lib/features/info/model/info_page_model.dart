import '../../../core/app/app_name.dart';
import '../../../core/services/platform_capabilities.dart';
import '../../../core/utils/support_contact.dart';

enum InfoKind { about, privacy, terms }

enum InfoAction {
  licenses('View licenses');

  const InfoAction(this.label);

  final String label;
}

// A section is an ordered list of blocks, because some sections put a
// paragraph after their bullets.
sealed class InfoBlock {
  const InfoBlock();
}

class InfoParagraph extends InfoBlock {
  const InfoParagraph(this.text);

  final String text;
}

class InfoBullets extends InfoBlock {
  const InfoBullets(this.items);

  final List<String> items;
}

class InfoSection {
  const InfoSection({this.heading, this.blocks = const [], this.action});

  // Null for an intro card that has no heading.
  final String? heading;
  final List<InfoBlock> blocks;
  final InfoAction? action;
}

class InfoPage {
  const InfoPage({
    required this.title,
    required this.sections,
    this.lastUpdated,
  });

  final String title;
  final List<InfoSection> sections;
  final String? lastUpdated;

  // The About page shows the installed version and what this platform
  // supports, so it is built per call.
  factory InfoPage.of(
    InfoKind kind, {
    required String version,
    required PlatformCapabilities capabilities,
  }) =>
      switch (kind) {
        InfoKind.about => _about(version, capabilities),
        InfoKind.privacy => _privacy,
        InfoKind.terms => _terms,
      };
}

const _lastUpdated = 'Last updated: 1 November 2026';

InfoPage _about(String version, PlatformCapabilities capabilities) => InfoPage(
      title: 'About $appName',
      sections: [
        _aboutIntro,
        _whatYouCanDo(capabilities),
        _aboutPrivacy,
        InfoSection(heading: 'Version', blocks: [InfoParagraph(version)]),
        ..._aboutOutro,
      ],
    );

const _aboutIntro = InfoSection(
  heading: appName,
  blocks: [
    InfoParagraph(
        '$appName is a private, offline music player. It plays the music already stored on your device, with no account, no subscription and no internet connection required.'),
  ],
);

// Folders and the playback notification only exist on Android, so the
// iPhone list leaves them out.
InfoSection _whatYouCanDo(PlatformCapabilities capabilities) => InfoSection(
      heading: 'What you can do',
      blocks: [
        InfoBullets([
          capabilities.supportsFolders
              ? 'Browse your library by songs, folders, albums and artists'
              : 'Browse your library by songs, albums and artists',
          'Search your music instantly',
          'Build playlists and mark favourites',
          'Control playback with a queue, sleep timer and playback speed',
          capabilities.hasPlaybackNotification
              ? 'Keep music playing in the background, with notification and lock screen controls'
              : 'Keep music playing in the background, with lock screen controls',
          'Review recently played and most played songs',
          if (capabilities.supportsFolders)
            'Hide folders you do not want in your library',
          'Switch between dark and light themes',
        ]),
      ],
    );

const _aboutPrivacy = InfoSection(
  heading: 'Your privacy',
  blocks: [
    InfoParagraph(
        'Your music and your data stay on your device. $appName does not collect, upload or share your information. Read the Privacy policy for details.'),
  ],
);

const _aboutOutro = [
  InfoSection(
    heading: 'Support',
    blocks: [
      InfoParagraph('Questions, feedback or problems? Write to $supportEmail.'),
    ],
  ),
  InfoSection(
    heading: 'Open-source licenses',
    action: InfoAction.licenses,
  ),
];

const _privacy = InfoPage(
  title: 'Privacy policy',
  lastUpdated: _lastUpdated,
  sections: [
    InfoSection(
      blocks: [
        InfoParagraph(
            'This Privacy policy explains how $appName ("the app", "we", "us") handles information when you use the app. In short: $appName works entirely on your device and does not collect, transmit or share your personal information.'),
      ],
    ),
    InfoSection(
      heading: '1. Information we do not collect',
      blocks: [
        InfoParagraph(
            'We do not collect, store on our servers, sell, rent or share any personal information. $appName has no user accounts, and it does not use advertising, analytics, crash-reporting or tracking tools. The app does not need an internet connection to work and does not send any data from your device.'),
      ],
    ),
    InfoSection(
      heading: '2. Information that stays on your device',
      blocks: [
        InfoParagraph(
            'To work as a music player, the app uses the following information, which is processed and stored only on your device:'),
        InfoBullets([
          'Your music library details, such as song titles, artists, albums, durations and file locations, read from your device\'s media library and, on Android, from the audio files in your device\'s storage',
          'Your playlists, favourites and hidden folders',
          'Your listening history, such as recently played songs and play counts',
          'Your app settings, such as the theme and library options',
        ]),
        InfoParagraph(
            'This information is kept in the app\'s private storage. We cannot see it and the app never uploads it. If your device\'s own backup is turned on (Android backup or iCloud Backup), it may include this data in your personal device backup, which is controlled by your Google or Apple account, not by us.'),
      ],
    ),
    InfoSection(
      heading: '3. Permissions',
      blocks: [
        InfoBullets([
          'Audio / music access: needed to find and play the music stored on your device. On newer versions of Android this appears as permission to access music and audio; on older versions it appears as storage access. On iPhone this appears as Media and Apple Music access. The app uses this permission only to list and play your audio files and does not read your photos, videos, contacts, location, camera or microphone.',
          'Background playback: To keep your music playing when the screen is off or you switch to another app, $appName uses your device\'s standard media playback features. On Android this is a media playback service with a playback notification, and it uses the foreground service and wake lock permissions that Android grants automatically, without asking you. On iPhone it uses the audio background mode. This does not give the app access to any additional data.',
        ]),
        InfoParagraph(
            '$appName does not ask for permission to send notifications. The playback notification and lock screen controls only show the song that is playing and the playback buttons.'),
        InfoParagraph(
            'You can withdraw audio access at any time in your device\'s Settings. The app will then be unable to show your music.'),
      ],
    ),
    InfoSection(
      heading: '4. Third-party services',
      blocks: [
        InfoParagraph(
            '$appName does not integrate third-party services that collect data. Fonts and animations used by the app are bundled inside it, so the app does not contact any server to load them.'),
      ],
    ),
    InfoSection(
      heading: '5. Children\'s privacy',
      blocks: [
        InfoParagraph(
            'Because $appName collects no personal information, it can be used safely by people of all ages. We do not knowingly collect information from children.'),
      ],
    ),
    InfoSection(
      heading: '6. Data retention and deletion',
      blocks: [
        InfoParagraph(
            'Your data stays on your device until you remove it. You can delete individual playlists, favourites and hidden-folder settings inside the app. Uninstalling $appName, or clearing its storage in your device settings, permanently deletes all data the app has stored on your device; only a personal device backup (Android backup or iCloud Backup), if you use one, may still hold a copy. Because we hold no copy, we cannot restore it.'),
      ],
    ),
    InfoSection(
      heading: '7. Security',
      blocks: [
        InfoParagraph(
            'Your data is stored in the app\'s private area of your device and is protected by your device\'s own security. We recommend keeping your device secured with a screen lock.'),
      ],
    ),
    InfoSection(
      heading: '8. Your rights',
      blocks: [
        InfoParagraph(
            'Because we do not collect or hold your personal data, there is nothing for us to access, correct, export or delete on our side. If you have any privacy question or request, contact us and we will respond.'),
      ],
    ),
    InfoSection(
      heading: '9. Changes to this policy',
      blocks: [
        InfoParagraph(
            'We may update this policy from time to time, for example when the app gains new features. The "Last updated" date at the top shows when it last changed. Continued use of the app after an update means you accept the updated policy.'),
      ],
    ),
    InfoSection(
      heading: '10. Contact us',
      blocks: [InfoParagraph(supportEmail)],
    ),
  ],
);

const _terms = InfoPage(
  title: 'Terms and conditions',
  lastUpdated: _lastUpdated,
  sections: [
    InfoSection(
      blocks: [
        InfoParagraph(
            'These Terms and conditions ("Terms") govern your use of $appName ("the app"). By installing or using the app you agree to these Terms. If you do not agree, please do not use the app.'),
      ],
    ),
    InfoSection(
      heading: '1. Licence',
      blocks: [
        InfoParagraph(
            'We grant you a personal, non-exclusive, non-transferable, revocable licence to install and use the app on devices you own or control, for your own non-commercial use.'),
      ],
    ),
    InfoSection(
      heading: '2. Your music',
      blocks: [
        InfoParagraph(
            '$appName is a player for audio files that are already on your device. We do not provide, host, sell or distribute any music. You are responsible for making sure you have the right to own and play the files you use with the app.'),
      ],
    ),
    InfoSection(
      heading: '3. Acceptable use',
      blocks: [
        InfoParagraph('You agree not to:'),
        InfoBullets([
          'Copy, modify, reverse engineer or attempt to extract the source code of the app, except where the law allows it',
          'Sell, rent, sublicense or redistribute the app',
          'Use the app for any unlawful purpose or in a way that infringes the rights of others',
          'Remove or alter any copyright or ownership notice in the app',
        ]),
      ],
    ),
    InfoSection(
      heading: '4. Permissions',
      blocks: [
        InfoParagraph(
            'The app needs permission to access audio files on your device to work. You can change this permission in your device settings at any time. Without it, the app cannot show or play your music.'),
        InfoParagraph(
            'On Android, $appName runs a media playback service while music is playing so playback can continue in the background; you can stop it by pausing playback and dismissing the notification.'),
      ],
    ),
    InfoSection(
      heading: '5. Intellectual property',
      blocks: [
        InfoParagraph(
            'The app, including its name, logo, design, text and code, is owned by its developer and protected by copyright and other laws. These Terms do not transfer any ownership to you. Third-party components remain under their own licences, which you can view in About, Open-source licenses.'),
      ],
    ),
    InfoSection(
      heading: '6. Privacy',
      blocks: [
        InfoParagraph(
            'Your use of the app is also described by our Privacy policy, which explains that your data stays on your device.'),
      ],
    ),
    InfoSection(
      heading: '7. Updates and availability',
      blocks: [
        InfoParagraph(
            'We may update, change or discontinue features of the app at any time. We do not promise that the app will always be available or free of errors.'),
      ],
    ),
    InfoSection(
      heading: '8. Disclaimer of warranties',
      blocks: [
        InfoParagraph(
            'The app is provided "as is" and "as available", without warranties of any kind, whether express or implied, including fitness for a particular purpose and non-infringement. We do not guarantee that the app will meet every requirement or work with every audio file format or device.'),
      ],
    ),
    InfoSection(
      heading: '9. Limitation of liability',
      blocks: [
        InfoParagraph(
            'To the maximum extent permitted by law, we are not liable for any indirect, incidental, special or consequential damages, or for loss of data, arising from your use of or inability to use the app. Our total liability for any claim relating to the app will not exceed the amount you paid for it, which for a free app is zero. Nothing in these Terms limits any rights you have under mandatory consumer law.'),
      ],
    ),
    InfoSection(
      heading: '10. Termination',
      blocks: [
        InfoParagraph(
            'You may stop using the app at any time by uninstalling it. We may end your licence if you breach these Terms. When the licence ends, you must stop using the app and delete it.'),
      ],
    ),
    InfoSection(
      heading: '11. App store providers',
      blocks: [
        InfoParagraph(
            'These Terms are between you and the developer of $appName, not between you and Apple Inc. or Google LLC. Those companies are not responsible for the app, its maintenance or support.'),
      ],
    ),
    InfoSection(
      heading: '12. Governing law',
      blocks: [
        InfoParagraph(
            'These Terms are governed by the laws of India. Any dispute will be subject to the courts of Kerala, India, unless mandatory law in your country of residence says otherwise.'),
      ],
    ),
    InfoSection(
      heading: '13. Changes to these Terms',
      blocks: [
        InfoParagraph(
            'We may update these Terms from time to time. The "Last updated" date shows the latest version. Continuing to use the app after a change means you accept the updated Terms.'),
      ],
    ),
    InfoSection(
      heading: '14. Contact us',
      blocks: [InfoParagraph(supportEmail)],
    ),
  ],
);
