import 'package:flutter/material.dart';

import '../../../core/models/song_model.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/services/song_actions.dart';
import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';
import 'action_bar_item.dart';
import 'sleep_countdown_label.dart';
import 'sleep_timer_sheet.dart';
import 'speed_sheet.dart';

class PlayerActionBar extends StatelessWidget {
  const PlayerActionBar({
    super.key,
    required this.player,
    required this.song,
    required this.speedLabel,
    required this.sleepActive,
  });

  final PlayerViewModel player;
  final Song song;
  final String speedLabel;
  final bool sleepActive;

  static const double _height = 68;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return Container(
      height: _height,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: tokens.glass,
        borderRadius: BorderRadius.circular(AppRadii.nav),
        border: Border.all(color: tokens.line),
      ),
      child: Row(
        children: [
          ActionBarItem(
            icon: Icons.playlist_add_rounded,
            label: 'Playlist',
            onTap: () => addToPlaylist(context, song),
          ),
          ActionBarItem(
            icon: Icons.bedtime_outlined,
            label: 'Sleep timer',
            active: sleepActive,
            labelBuilder: sleepActive
                ? (context) => SleepCountdownLabel(player: player)
                : null,
            onTap: () => showSleepTimerSheet(context),
          ),
          ActionBarItem(
            icon: Icons.speed_rounded,
            label: speedLabel,
            tooltip: 'Playback speed',
            onTap: () => showSpeedSheet(context),
          ),
          ActionBarItem(
            icon: Icons.queue_music_rounded,
            label: 'Queue',
            onTap: () => NavigationService.pushNamed(AppRoutes.queue),
          ),
        ],
      ),
    );
  }
}
