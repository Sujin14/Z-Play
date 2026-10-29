import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';

class BigPlayButton extends StatefulWidget {
  const BigPlayButton(
      {super.key, required this.playing, required this.onPressed});

  final bool playing;
  final VoidCallback onPressed;

  @override
  State<BigPlayButton> createState() => _BigPlayButtonState();
}

class _BigPlayButtonState extends State<BigPlayButton> {
  bool _pressed = false;

  static const double _size = 78;
  static const double _iconSize = 40;
  static const double _pressedScale = 0.94;
  static const _pressAnimation = Duration(milliseconds: 120);
  static const double _glowAlpha = 0.4;
  static const double _glowBlur = 28;
  static const Offset _glowOffset = Offset(0, 8);

  @override
  Widget build(BuildContext context) {
    final label = widget.playing ? 'Pause' : 'Play';
    return Semantics(
      button: true,
      label: label,
      child: Tooltip(
        message: label,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onPressed,
          child: AnimatedScale(
            scale: _pressed ? _pressedScale : 1,
            duration: _pressAnimation,
            child: Container(
              width: _size,
              height: _size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.action,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.neon.withValues(alpha: _glowAlpha),
                    blurRadius: _glowBlur,
                    offset: _glowOffset,
                  ),
                ],
              ),
              child: Icon(
                widget.playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                size: _iconSize,
                color: AppColors.onAccent,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
