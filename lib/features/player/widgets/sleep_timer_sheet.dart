import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/player_view_model.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/ghost_button.dart';
import '../../../core/widgets/pill_chip.dart';
import '../view_model/player_screen_view_model.dart';
import 'sleep_countdown_card.dart';

Future<void> showSleepTimerSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (context) => const SleepTimerSheet(),
  );
}

class SleepTimerSheet extends StatelessWidget {
  const SleepTimerSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerViewModel>();
    final sleep = PlayerScreenViewModel(player);
    final active = sleep.isSleepActive;
    const minutesOptions = PlayerScreenViewModel.sleepMinutes;

    Widget chip(String label, bool selected, VoidCallback onTap) {
      return PillChip(
          label: label, selected: selected, expand: true, onTap: onTap);
    }

    return AppSheet(
      title: 'Sleep timer',
      subtitle: 'Music stops when the time is up.',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (active) ...[
              SleepCountdownCard(player: player),
              const SizedBox(height: 16),
            ],
            for (var row = 0; row < minutesOptions.length; row += 2) ...[
              Row(
                children: [
                  for (final minutes in minutesOptions.skip(row).take(2)) ...[
                    if (minutes != minutesOptions[row])
                      const SizedBox(width: 10),
                    Expanded(
                      child: chip(
                        '$minutes min',
                        sleep.isSleepChoice(minutes),
                        () {
                          player.startSleepTimer(Duration(minutes: minutes));
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 10),
            ],
            chip('End of track', player.stopAfterCurrent, () {
              player.sleepAfterCurrentTrack();
              Navigator.pop(context);
            }),
            if (active) ...[
              const SizedBox(height: 10),
              GhostButton(
                label: 'Cancel timer',
                accent: true,
                expand: true,
                onPressed: () {
                  player.cancelSleep();
                  Navigator.pop(context);
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
