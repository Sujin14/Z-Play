import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/state/player_view_model.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/widgets/app_sheet.dart';
import '../../../core/widgets/pill_chip.dart';
import '../view_model/player_screen_view_model.dart';

Future<void> showSpeedSheet(BuildContext context) {
  return showAppSheet<void>(
    context,
    builder: (sheetContext) => const SpeedSheet(),
  );
}

class SpeedSheet extends StatelessWidget {
  const SpeedSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final player = context.watch<PlayerViewModel>();
    final screen = PlayerScreenViewModel(player);
    const rates = PlayerScreenViewModel.speeds;
    Widget chip(double rate) => Expanded(
          child: PillChip(
            label: formatSpeed(rate),
            selected: screen.isCurrentSpeed(rate),
            expand: true,
            onTap: () {
              player.setSpeed(rate);
              Navigator.pop(context);
            },
          ),
        );
    // Three on top, two below, matching the sleep timer's chip grid.
    return AppSheet(
      title: 'Playback speed',
      subtitle: 'Applies to every song you play.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            chip(rates[0]),
            const SizedBox(width: 10),
            chip(rates[1]),
            const SizedBox(width: 10),
            chip(rates[2])
          ]),
          const SizedBox(height: 10),
          Row(children: [
            chip(rates[3]),
            const SizedBox(width: 10),
            chip(rates[4])
          ]),
        ],
      ),
    );
  }
}
