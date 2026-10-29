import 'package:flutter/material.dart';

import '../theme/app_tokens.dart';

class EqualizerBars extends StatefulWidget {
  const EqualizerBars({super.key, this.animate = true, this.color});

  final bool animate;
  final Color? color;

  @override
  State<EqualizerBars> createState() => _EqualizerBarsState();
}

class _EqualizerBarsState extends State<EqualizerBars>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _cycle,
  );

  static const _cycle = Duration(milliseconds: 900);
  // Offsets into the cycle so the three bars never move in step.
  static const _phases = [0.0, 0.35, 0.7];
  static const double _size = 18;
  static const double _barWidthDivisor = 6;
  static const double _minHeight = 0.3;
  static const double _bounce = 0.7;

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void didUpdateWidget(EqualizerBars oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.animate && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTokens.of(context).accent;
    final barWidth = _size / _barWidthDivisor;
    return SizedBox.square(
      dimension: _size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final phase in _phases)
                Container(
                  width: barWidth,
                  height: _size * _height(phase),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(barWidth / 2),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // A triangle wave eased into a bounce, kept above _minHeight so a bar
  // never disappears.
  double _height(double phase) {
    final t = (_controller.value + phase) % 1;
    final wave = t < 0.5 ? t * 2 : (1 - t) * 2;
    return _minHeight + _bounce * Curves.easeInOut.transform(wave);
  }
}
