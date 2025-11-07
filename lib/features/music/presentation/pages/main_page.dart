import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/music_viewmodel.dart';
import '../widgets/custom_bottom_navigation.dart';
import '../widgets/mini_player/mini_player.dart';
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

  final List<Widget> _pages = const [
    HomePage(),
    FavoritesPage(),
    PlaylistScreen(),
    SettingsPage(),
  ];

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final musicViewModel = Provider.of<MusicViewModel>(context);

    return Scaffold(
      extendBody: true,
      body: Stack(
        children: [
          _pages[_currentIndex],
          if (musicViewModel.currentMusicFile != null)
            Positioned(
              bottom: 70,
              left: 12,
              right: 12,
              child: MiniPlayer(musicViewModel: musicViewModel),
            ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigation(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
      ),
    );
  }
}
