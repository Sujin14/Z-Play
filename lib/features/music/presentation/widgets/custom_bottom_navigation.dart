import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: theme.colorScheme.surfaceContainerHighest,
      buttonBackgroundColor: theme.colorScheme.trendingIcon,
      height: 60,
      index: currentIndex,
      items: [
        Icon(Icons.home, size: 30, color: theme.textTheme.bodyLarge!.color),
        Icon(Icons.favorite, size: 30, color: theme.textTheme.bodyLarge!.color),
        Icon(Icons.queue_music_rounded, size: 30, color: theme.textTheme.bodyLarge!.color),
        Icon(Icons.settings, size: 30, color: theme.textTheme.bodyLarge!.color),
      ],
      onTap: onTap,
    );
  }
}