import 'package:flutter/material.dart';
import 'package:musicplayer/view/settings/terms_and_conditions_page.dart';
import 'recently_played_page.dart';
import 'about_us_page.dart';
import 'most_played_page.dart';
import 'privacy_policy_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(fontSize: hi / 45, color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const RecentlyPlayedPage()),
                    );
                  },
                  leading: const Icon(Icons.history, color: Colors.white),
                  title: Text(
                    'Recently Played',
                    style: TextStyle(fontSize: hi / 50, color: Colors.white),
                  ),
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const MostPlayedPage()),
                    );
                  },
                  leading: const Icon(Icons.watch_later, color: Colors.white),
                  title: Text(
                    'Most Played',
                    style: TextStyle(fontSize: hi / 50, color: Colors.white),
                  ),
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.info, color: Colors.white),
                  title: Text(
                    'About',
                    style: TextStyle(fontSize: hi / 50, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const AboutPage(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.privacy_tip, color: Colors.white),
                  title: Text(
                    'Privacy Policy',
                    style: TextStyle(fontSize: hi / 50, color: Colors.white),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PrivacyPolicyPage(),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TermsAndConditionsPage()),
                    );
                  },
                  leading: const Icon(Icons.description, color: Colors.white),
                  title: Text(
                    'Terms & Conditions',
                    style: TextStyle(fontSize: hi / 50, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: Text(
              'Version 1.0.0',
              style: TextStyle(fontSize: hi / 55, color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }
}
