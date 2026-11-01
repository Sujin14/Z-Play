import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'ghost_button.dart';
import 'primary_button.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.message,
    this.actionLabel,
    this.actionIcon,
    this.onAction,
    this.secondaryActionLabel,
    this.secondaryActionIcon,
    this.onSecondaryAction,
    this.error = false,
    this.badge,
    this.scrollable = true,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final IconData? actionIcon;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final IconData? secondaryActionIcon;
  final VoidCallback? onSecondaryAction;
  final bool error;

  // Replaces the rings and icon (e.g. the large "404").
  final Widget? badge;

  // False inside slivers (SliverFillRemaining), which can't hold a nested
  // scroll view.
  final bool scrollable;

  static const double _outerRing = 140;
  static const double _innerRing = 104;
  static const double _badge = 68;
  static const double _iconSize = 30;
  static const double _ringAlpha = 0.18;
  static const _padding = EdgeInsets.symmetric(horizontal: 36, vertical: 24);

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final ring =
        (error ? tokens.heart : tokens.accent).withValues(alpha: _ringAlpha);
    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        badge ??
            Container(
              width: _outerRing,
              height: _outerRing,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ring),
              ),
              alignment: Alignment.center,
              child: Container(
                width: _innerRing,
                height: _innerRing,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: ring),
                ),
                alignment: Alignment.center,
                child: Container(
                  width: _badge,
                  height: _badge,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: error ? null : AppColors.action,
                    color: error ? tokens.heart : null,
                  ),
                  child: Icon(icon, size: _iconSize, color: AppColors.onAccent),
                ),
              ),
            ),
        const SizedBox(height: 28),
        Text(title, textAlign: TextAlign.center, style: text.headlineSmall),
        if (message != null) ...[
          const SizedBox(height: 10),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: text.bodyLarge?.copyWith(color: tokens.text2),
          ),
        ],
        if (actionLabel != null) ...[
          const SizedBox(height: 24),
          PrimaryButton(
              label: actionLabel!, icon: actionIcon, onPressed: onAction),
        ],
        if (secondaryActionLabel != null) ...[
          const SizedBox(height: 12),
          GhostButton(
            label: secondaryActionLabel!,
            icon: secondaryActionIcon,
            onPressed: onSecondaryAction,
          ),
        ],
      ],
    );
    return Center(
      child: scrollable
          ? SingleChildScrollView(padding: _padding, child: content)
          : Padding(padding: _padding, child: content),
    );
  }
}
