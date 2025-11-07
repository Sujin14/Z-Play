import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import '../../../../../constants/themes.dart';

class GlassListTile extends StatelessWidget {
  final String title;
  final IconData leadingIcon;
  final Widget trailing;
  final VoidCallback onTap;
  final Color accentColor;
  final double marqueeHeight;

  const GlassListTile({
    super.key,
    required this.title,
    required this.leadingIcon,
    required this.trailing,
    required this.onTap,
    required this.accentColor,
    required this.marqueeHeight,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: theme.colorScheme.glassFill,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: theme.colorScheme.glassBorder),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.glassShadow,
                    blurRadius: 8,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    height: 56,
                    width: 56,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: LinearGradient(
                        colors: [
                          accentColor.withOpacity(0.18),
                          theme.colorScheme.tertiary.withOpacity(0.12)
                        ],
                      ),
                      border: Border.all(color: accentColor.withOpacity(0.12)),
                      boxShadow: [
                        BoxShadow(
                          color: accentColor.withOpacity(0.07),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(leadingIcon, color: accentColor, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SizedBox(
                      height: marqueeHeight,
                      child: Marquee(
                        text: title,
                        style: style(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: theme.textTheme.bodyLarge!.color,
                        ),
                        blankSpace: 20,
                        velocity: 30,
                        startPadding: 10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  trailing,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
