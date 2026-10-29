enum InfoKind { about, privacy, terms }

class InfoSection {
  const InfoSection({required this.heading, required this.body});

  final String heading;
  final String body;
}

class InfoPage {
  const InfoPage({required this.title, required this.sections});

  final String title;
  final List<InfoSection> sections;

  factory InfoPage.of(InfoKind kind) => switch (kind) {
        InfoKind.about => _about,
        InfoKind.privacy => _privacy,
        InfoKind.terms => _terms,
      };
}

// Shown word for word; the legal pages must not be reworded here.
const _about = InfoPage(
  title: 'About Z-PLAY',
  sections: [
    InfoSection(
      heading: 'Offline music, on this device',
      body:
          'Z-PLAY plays music that is already stored on your phone or computer. It does not stream, and it does not upload your library.',
    ),
    InfoSection(
      heading: 'What you can do',
      body:
          'Browse songs, folders, albums, and artists. Search by title, artist, album, or genre. Build playlists, keep favorites, and pick up a saved queue. Shuffle, repeat, playback speed, and a sleep timer stay on the device.',
    ),
    InfoSection(
      heading: 'Version',
      body: '1.0.0+3',
    ),
  ],
);

const _privacy = InfoPage(
  title: 'Privacy policy',
  sections: [
    InfoSection(
      heading: 'Last updated: October 23, 2026',
      body:
          'Z-PLAY reads audio files on your device so it can list and play them. Playlists, favorites, play counts, and the last queue are stored locally with Hive. Nothing is sent to a server.',
    ),
    InfoSection(
      heading: 'Permission',
      body:
          'On Android 13 and newer the app asks for access to audio files. On older Android versions it asks for storage read access. That access is used to scan mounted storage and the system music index.',
    ),
    InfoSection(
      heading: 'Contact',
      body: 'Questions about privacy: support@zplay.com.',
    ),
  ],
);

const _terms = InfoPage(
  title: 'Terms and conditions',
  sections: [
    InfoSection(
      heading: 'Last updated: October 23, 2026',
      body: 'By using Z-PLAY you agree to these terms.',
    ),
    InfoSection(
      heading: 'Use of the app',
      body:
          'Z-PLAY is for personal playback of audio files you already have. Do not use it to break copyright or any other law.',
    ),
    InfoSection(
      heading: 'The app is provided as is',
      body:
          'There is no warranty. We are not liable for damage from using or being unable to use the app, including missing files or interrupted playback.',
    ),
    InfoSection(
      heading: 'Contact',
      body: 'Questions: support@zplay.com.',
    ),
  ],
);
