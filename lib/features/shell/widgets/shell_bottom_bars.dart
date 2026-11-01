import 'package:flutter/material.dart';

import '../../../core/navigation/mini_player_anchor.dart';
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

  @override
  Widget build(BuildContext context) {
    final hasSong = player.current != null;
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(MiniPlayerAnchor.margin, 0,
            MiniPlayerAnchor.margin, MiniPlayerAnchor.margin),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasSong)
              Padding(
                padding: const EdgeInsets.only(bottom: MiniPlayerAnchor.gap),
                child: SizedBox(
                  height: MiniPlayerAnchor.height,
                  child: MiniPlayer(player: player, onOpen: onOpenPlayer),
                ),
              ),
            SizedBox(
              height: MiniPlayerAnchor.navHeight,
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
