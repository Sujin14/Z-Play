import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:musicplayer/view/favorite/favorites_page.dart';
import 'package:musicplayer/view/home/home_page.dart';
import 'package:musicplayer/view/playlist/playlist_page.dart';
import 'package:musicplayer/view/settings/settings_page.dart';
import 'package:musicplayer/view_model/providers/ui_provider.dart';
import 'package:provider/provider.dart';

/// CustomBottomNavigationBar Widget
/// - A bottom navigation bar with curved animation.
/// - Allows navigation between Home, Favorites, Playlist, and Settings pages.
class CustomBottomNavigationBar extends StatelessWidget {
  // List of pages to be displayed on navigation
  final List<Widget> _pages = [
    const HomePage(),
    const FavoritesPage(),
    const PlaylistScreen(),
    const SettingsPage(),
  ];

  CustomBottomNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final tabProvider = Provider.of<TabProvider>(context);

    return Scaffold(
      body: _pages[tabProvider.currentIndex], // Display the current page
      bottomNavigationBar: CurvedNavigationBar(
        index: tabProvider.currentIndex, // Current index for the active tab
        height: 60.0, // Height of the navigation bar
        color: Theme.of(context).primaryColor, // Navigation bar color
        backgroundColor: const Color(0xFF1A1A2E), // Background color
        animationCurve:
            Curves.easeInOut, // Animation curve for smooth transition
        animationDuration:
            const Duration(milliseconds: 300), // Animation duration
        onTap: (index) {
          tabProvider.onTabTapped(index, context); // Update current tab index
        },
        items: <Widget>[
          // Home Tab Icon
          Icon(
            Icons.home,
            size: hi / 30,
            color: tabProvider.currentIndex == 0 ? Colors.white : Colors.black,
          ),
          // Favorite Tab Icon
          Icon(
            Icons.favorite,
            size: hi / 30,
            color: tabProvider.currentIndex == 1 ? Colors.white : Colors.black,
          ),
          // Playlist Tab Icon
          Icon(
            Icons.playlist_play,
            size: hi / 30,
            color: tabProvider.currentIndex == 2 ? Colors.white : Colors.black,
          ),
          // Settings Tab Icon
          Icon(
            Icons.settings,
            size: hi / 30,
            color: tabProvider.currentIndex == 3 ? Colors.white : Colors.black,
          ),
        ],
      ),
    );
  }
}
