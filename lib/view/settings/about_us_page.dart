import 'package:flutter/material.dart';

/// **About Page**
/// - Displays app information, features, technologies, and developer details.
class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    const String appName = "Z Music";
    const String developerName = "Sujin K Suresh";
    const String gmail = "sujinsuresh1422002@gmail.com";
    const String appVersion = "1.0.0";

    final double hi = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _buildAppBar(hi),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionTitle(context, 'About $appName'),
                _buildText(
                  '$appName provides a seamless music experience with customizable playlists, dark mode, and real-time song recommendations. It is your go-to app for all your music needs.',
                  hi,
                ),
                _buildSectionTitle(context, 'Purpose'),
                _buildText(
                  'Our goal is to deliver an intuitive and enjoyable music experience. Whether creating playlists or discovering new music, $appName offers tools to enhance your listening habits.',
                  hi,
                ),
                _buildSectionTitle(context, 'Features'),
                _buildBulletPoints([
                  'Customizable playlists: Create and manage playlists with ease.',
                  'Offline access: Enjoy your music even without an internet connection.',
                  'Favorite songs: Mark songs as favorites for quick access.',
                ], hi),
                _buildSectionTitle(context, 'Technologies Used'),
                _buildBulletPoints([
                  'Flutter: Built using Flutter for a fast and cross-platform experience.',
                  'Hive: Secure and fast local storage for music playlists and user preferences.',
                  'Provider: State management using the Provider package for efficient app control.',
                ], hi),
                _buildSectionTitle(context, 'Version'),
                _buildBoldText(appVersion, hi),
                _buildSectionTitle(context, 'Developer'),
                _buildText(developerName, hi),
                _buildSectionTitle(context, 'Contact Us'),
                _buildText(
                  'For support or inquiries, contact us at:\nEmail: $gmail',
                  hi,
                ),
                _buildSectionTitle(context, 'Credits'),
                _buildBulletPoints([
                  'Icons provided by Flutter.',
                  'Special thanks to all developers who contributed to open-source libraries used in this app.',
                ], hi),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// **App Bar**
  AppBar _buildAppBar(double hi) {
    return AppBar(
      title: Text(
        'About',
        style: TextStyle(fontSize: hi / 50),
      ),
    );
  }

  /// **Reusable Widget for Section Titles**
  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 10),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
    );
  }

  /// **Reusable Widget for Normal Text**
  Widget _buildText(String text, double hi) {
    return Text(
      text,
      style: TextStyle(fontSize: hi / 50),
    );
  }

  /// **Reusable Widget for Bold Text**
  Widget _buildBoldText(String text, double hi) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, fontSize: hi / 50),
    );
  }

  /// **Reusable Widget for Bullet Points**
  Widget _buildBulletPoints(List<String> points, double hi) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: points
          .map(
            (point) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2.0),
              child: Text(
                '- $point',
                style: TextStyle(fontSize: hi / 50),
              ),
            ),
          )
          .toList(),
    );
  }
}
