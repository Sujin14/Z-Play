import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';
import 'package:provider/provider.dart';
import '../viewmodels/music_viewmodel.dart';
import '../widgets/custom_bottom_navigation.dart';
import 'home_page.dart';
import 'favorites_page.dart';
import 'playlist_page.dart';
import 'settings_page.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const FavoritesPage(),
    const PlaylistScreen(),
    const SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final musicViewModel = Provider.of<MusicViewModel>(context);
    return Scaffold(
      body: Stack(
        children: [
          _pages[_currentIndex],
          if (musicViewModel.currentMusicFile != null)
            Positioned(
              bottom: 60,
              left: 0,
              right: 0,
              child: _buildMiniPlayer(context, musicViewModel),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }

  Widget _buildMiniPlayer(BuildContext context, MusicViewModel musicViewModel) {
    final theme = Theme.of(context);
    return Dismissible(
      key: ValueKey('miniPlayer'),
      direction: DismissDirection.startToEnd,
      onDismissed: (_) {
        musicViewModel.stopAndClearMusic();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.shadowColor,
              blurRadius: 5,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                musicViewModel.currentMusicFile!.title,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: theme.textTheme.bodyLarge!.color, fontWeight: FontWeight.bold),
              ),
            ),
            IconButton(
              icon: Icon(
                musicViewModel.isPlaying ? Icons.pause : Icons.play_arrow,
                color: theme.textTheme.bodyLarge!.color,
              ),
              onPressed: () {
                if (musicViewModel.isPlaying) {
                  musicViewModel.pauseMusic();
                } else {
                  musicViewModel.resumeMusic();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}