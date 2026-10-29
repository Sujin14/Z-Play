import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

// Returns an Expanded, so it must sit directly in the action bar's Row.
class ActionBarItem extends StatelessWidget {
  const ActionBarItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.active = false,
    this.labelBuilder,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool active;
  // Replaces the plain label, e.g. with the live sleep countdown.
  final WidgetBuilder? labelBuilder;
  // Defaults to the label.
  final String? tooltip;

  static const double _radius = 28;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final color = active ? tokens.accentText : tokens.text;
    final style =
        Theme.of(context).textTheme.labelMedium?.copyWith(color: color);
    return Expanded(
      child: Tooltip(
        message: tooltip ?? label,
        child: Material(
          color: active ? tokens.chip : Colors.transparent,
          borderRadius: BorderRadius.circular(_radius),
          child: InkWell(
            borderRadius: BorderRadius.circular(_radius),
            onTap: onTap,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: _iconSize, color: color),
                const SizedBox(height: 3),
                DefaultTextStyle.merge(
                  style: style,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  child: labelBuilder?.call(context) ?? Text(label),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
