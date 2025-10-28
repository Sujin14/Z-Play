import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Privacy Policy',
          style: style(fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Z-PLAY Privacy Policy',
                style: style(fontSize: hi / 40, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Text(
                'Last updated: October 25, 2025\n\n'
                'Z-PLAY is an offline music player and does not collect, store, or transmit any personal data. '
                'All data used by the app (e.g., music files, playlists, favorites) is stored locally on your device.',
                style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              Text(
                'Permissions',
                style: style(fontSize: hi / 45, fontWeight: FontWeight.bold),
              ),
              Text(
                'Z-PLAY requires storage permission to access and play music files stored on your device. '
                'This permission is used solely to scan and retrieve audio files.',
                style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              Text(
                'Data Usage',
                style: style(fontSize: hi / 45, fontWeight: FontWeight.bold),
              ),
              Text(
                'Since Z-PLAY operates offline, no data is shared with third parties or transmitted over the internet. '
                'Your music files, playlists, and preferences remain private on your device.',
                style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
              ),
              const SizedBox(height: 20),
              Text(
                'Contact Us',
                style: style(fontSize: hi / 45, fontWeight: FontWeight.bold),
              ),
              Text(
                'If you have any questions about our privacy practices, please contact us at support@zplay.com.',
                style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
      ),
    );
  }
}