import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'About Z-PLAY',
          style:
              style(fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Z-PLAY: Your Offline Music Companion',
              style: style(fontSize: hi / 40, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Text(
              'Z-PLAY is a lightweight, offline music player designed to provide a seamless music listening experience. '
              'Browse, play, and organize your music files stored on your device with ease. '
              'Create playlists, manage favorites, and enjoy your music without an internet connection.',
              style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 20),
            Text(
              'Features:',
              style: style(fontSize: hi / 45, fontWeight: FontWeight.bold),
            ),
            Text(
              '- Play local audio files (MP3, WAV, AAC, OGG, FLAC)\n'
              '- Create and manage playlists\n'
              '- Mark songs as favorites\n'
              '- Track recently played and most played songs\n'
              '- Customizable dark/light theme\n'
              '- Smooth and intuitive UI',
              style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
            ),
            const SizedBox(height: 20),
            Text(
              'Version: 1.0.0+3',
              style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
            ),
            const Spacer(),
            Center(
              child: Text(
                'Developed with ❤️ by Z-PLAY Team',
                style: style(fontSize: hi / 60, fontWeight: FontWeight.normal),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
