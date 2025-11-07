import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import '../../../../constants/themes.dart';

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
    return Container(
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: CurvedNavigationBar(
        backgroundColor: Colors.transparent,
        color: theme.colorScheme.glassFill,
        buttonBackgroundColor: theme.colorScheme.primary,
        height: 64,
        index: currentIndex,
        items: [
          Icon(Icons.home, size: 28, color: theme.textTheme.bodyLarge!.color),
          Icon(Icons.favorite,
              size: 28, color: theme.textTheme.bodyLarge!.color),
          Icon(Icons.queue_music_rounded,
              size: 28, color: theme.textTheme.bodyLarge!.color),
          Icon(Icons.settings,
              size: 28, color: theme.textTheme.bodyLarge!.color),
        ],
        onTap: onTap,
      ),
    );
  }
}