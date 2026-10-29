import 'package:flutter/material.dart';

import '../../../core/state/player_view_model.dart';
import '../model/nav_bar_item_model.dart';
import 'floating_nav_bar.dart';
import 'mini_player.dart';

// The mini player only takes space while a song is loaded.
class ShellBottomBars extends StatelessWidget {
  const ShellBottomBars({
    super.key,
    required this.player,
    required this.items,
    required this.currentIndex,
    required this.onTabSelected,
    required this.onOpenPlayer,
  });

  final PlayerViewModel player;
  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTabSelected;
  final VoidCallback onOpenPlayer;

  static const double _margin = 16;
  static const double _navHeight = 68;
  static const double _miniHeight = 64;
  // Mini player bottom edge sits 96px from the screen bottom.
  static const double _miniBottom = 96;
  static const double _miniGap = _miniBottom - _navHeight - _margin;

  @override
  Widget build(BuildContext context) {
    final hasSong = player.current != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(_margin, 0, _margin, _margin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasSong)
              Padding(
                padding: const EdgeInsets.only(bottom: _miniGap),
                child: SizedBox(
                  height: _miniHeight,
                  child: MiniPlayer(player: player, onOpen: onOpenPlayer),
                ),
              ),
            SizedBox(
              height: _navHeight,
              child: FloatingNavBar(
                items: items,
                currentIndex: currentIndex,
                onTap: onTabSelected,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
