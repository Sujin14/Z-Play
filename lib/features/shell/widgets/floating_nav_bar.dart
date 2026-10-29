import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';
import '../model/nav_bar_item_model.dart';

class FloatingNavBar extends StatelessWidget {
  const FloatingNavBar({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onTap,
  });

  final List<NavBarItem> items;
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const double _blur = 20;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final radius = BorderRadius.circular(AppRadii.nav);
    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: tokens.glass,
            borderRadius: radius,
            border: Border.all(color: tokens.line),
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Row(
              children: [
                for (var i = 0; i < items.length; i++)
                  Expanded(
                    child: _NavButton(
                      item: items[i],
                      selected: i == currentIndex,
                      onTap: () => onTap(i),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton(
      {required this.item, required this.selected, required this.onTap});

  final NavBarItem item;
  final bool selected;
  final VoidCallback onTap;

  static const double _radius = 28;
  static const double _height = 56;
  static const double _iconSize = 22;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final color = selected ? tokens.accentText : tokens.text;
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: selected ? tokens.chip : Colors.transparent,
        borderRadius: BorderRadius.circular(_radius),
        child: InkWell(
          borderRadius: BorderRadius.circular(_radius),
          onTap: onTap,
          child: SizedBox(
            height: _height,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(selected ? item.selectedIcon ?? item.icon : item.icon,
                    color: color, size: _iconSize),
                const SizedBox(height: 3),
                Text(
                  item.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .labelMedium
                      ?.copyWith(color: color),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
