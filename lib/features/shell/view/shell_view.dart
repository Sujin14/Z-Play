import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/widgets/gradient_scaffold.dart';
import '../model/nav_bar_item_model.dart';
import '../widgets/shell_bottom_bars.dart';

class ShellView extends StatefulWidget {
  const ShellView({super.key, required this.tabs});

  // One page per nav item, in the same order. Passed in so the shell doesn't
  // depend on the features it hosts.
  final List<Widget> tabs;

  @override
  State<ShellView> createState() => _ShellViewState();
}

class _ShellViewState extends State<ShellView> {
  int _index = 0;

  static const _items = [
    NavBarItem(
        icon: Icons.music_note_outlined,
        selectedIcon: Icons.music_note,
        label: 'Library'),
    NavBarItem(
        icon: Icons.favorite_border,
        selectedIcon: Icons.favorite,
        label: 'Favorites'),
    NavBarItem(icon: Icons.queue_music, label: 'Playlists'),
    NavBarItem(
        icon: Icons.settings_outlined,
        selectedIcon: Icons.settings,
        label: 'Settings'),
  ];

  // Extra room past the floating bars so the last row clears them
  // (176px total with the mini player, 100px without).
  static const double _scrollClearance = 16;

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerViewModel>();
    return GradientScaffold(
      // The body runs under the bars; Scaffold reports their height as
      // bottom padding, which list views in the tabs pick up.
      extendBody: true,
      body: Builder(
        builder: (context) {
          final media = MediaQuery.of(context);
          return MediaQuery(
            data: media.copyWith(
              padding: media.padding
                  .copyWith(bottom: media.padding.bottom + _scrollClearance),
            ),
            // IndexedStack keeps every tab alive, so each keeps its scroll
            // position, search text and selected sub-tab across switches.
            child: IndexedStack(index: _index, children: widget.tabs),
          );
        },
      ),
      bottomNavigationBar: ShellBottomBars(
        player: player,
        items: _items,
        currentIndex: _index,
        onTabSelected: (index) => setState(() => _index = index),
        onOpenPlayer: () => NavigationService.pushNamed(AppRoutes.player),
      ),
    );
  }
}
