import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

class ToggleSwitch extends StatelessWidget {
  const ToggleSwitch({super.key, required this.value, required this.onChanged});

  final bool value;
  // Null disables the switch.
  final ValueChanged<bool>? onChanged;

  static const _duration = Duration(milliseconds: 180);
  static const double _width = 52;
  static const double _height = 30;
  static const double _inset = 3;
  static const double _thumb = 24;
  static const double _disabledOpacity = 0.5;
  static const double _offTrackAlpha = 0.28;
  static const _thumbShadow =
      BoxShadow(color: Color(0x33000000), blurRadius: 4, offset: Offset(0, 1));

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final enabled = onChanged != null;
    return Semantics(
      toggled: value,
      enabled: enabled,
      child: GestureDetector(
        onTap: enabled ? () => onChanged!(!value) : null,
        child: Opacity(
          opacity: enabled ? 1 : _disabledOpacity,
          child: AnimatedContainer(
            duration: _duration,
            width: _width,
            height: _height,
            padding: const EdgeInsets.all(_inset),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(_height / 2),
              gradient: value ? AppColors.action : null,
              color:
                  value ? null : tokens.text2.withValues(alpha: _offTrackAlpha),
            ),
            child: AnimatedAlign(
              duration: _duration,
              curve: Curves.easeOutCubic,
              alignment: value ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: _thumb,
                height: _thumb,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [_thumbShadow],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
