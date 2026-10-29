import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/state/player_view_model.dart';
import '../view_model/player_screen_view_model.dart';

// Rebuilds every second so the countdown ticks.
class SleepCountdownLabel extends StatefulWidget {
  const SleepCountdownLabel({super.key, required this.player});

  final PlayerViewModel player;

  @override
  State<SleepCountdownLabel> createState() => _SleepCountdownLabelState();
}

class _SleepCountdownLabelState extends State<SleepCountdownLabel> {
  Timer? _tick;

  static const _interval = Duration(seconds: 1);

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
    return Text(PlayerScreenViewModel(widget.player).sleepLabel);
  }
}
