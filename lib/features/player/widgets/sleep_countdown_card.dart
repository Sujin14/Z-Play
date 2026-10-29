import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/state/player_view_model.dart';
import '../../../core/theme/app_tokens.dart';
import '../view_model/player_screen_view_model.dart';

// Rebuilds every second so the countdown and ring stay live.
class SleepCountdownCard extends StatefulWidget {
  const SleepCountdownCard({super.key, required this.player});

  final PlayerViewModel player;

  @override
  State<SleepCountdownCard> createState() => _SleepCountdownCardState();
}

class _SleepCountdownCardState extends State<SleepCountdownCard> {
  Timer? _tick;

  static const _interval = Duration(seconds: 1);
  static const double _radius = 20;
  static const double _ringSize = 60;
  static const double _ringStroke = 6;

  @override
  void initState() {
    super.initState();
    _tick = Timer.periodic(_interval, (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tick?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final sleep = PlayerScreenViewModel(widget.player);
    final endOfTrack = sleep.isEndOfTrack;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tokens.chip,
        borderRadius: BorderRadius.circular(_radius),
      ),
      child: Row(
        children: [
          SizedBox.square(
            dimension: _ringSize,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: sleep.sleepProgress,
                  strokeWidth: _ringStroke,
                  strokeCap: StrokeCap.round,
                  color: tokens.accentText,
                  backgroundColor: tokens.line,
                ),
                Icon(Icons.bedtime_outlined, color: tokens.accentText),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(sleep.sleepLabel,
                    style: endOfTrack ? text.titleLarge : text.headlineMedium),
                const SizedBox(height: 2),
                Text(sleep.sleepCaption, style: text.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
