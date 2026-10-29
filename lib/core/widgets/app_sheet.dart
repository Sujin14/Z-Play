import 'package:flutter/material.dart';

import '../theme/app_radii.dart';
import '../theme/app_tokens.dart';

const double _darkScrimAlpha = 0.55;
const double _lightScrimAlpha = 0.3;

// Wrap the content in AppSheet to get the handle and title.
Future<T?> showAppSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  final dark = Theme.of(context).brightness == Brightness.dark;
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: true,
    backgroundColor: AppTokens.of(context).sheet,
    barrierColor: Colors.black
        .withValues(alpha: dark ? _darkScrimAlpha : _lightScrimAlpha),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
    ),
    clipBehavior: Clip.antiAlias,
    builder: builder,
  );
}

class AppSheet extends StatelessWidget {
  const AppSheet({
    super.key,
    required this.child,
    this.title,
    this.subtitle,
    this.trailing,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 20),
  });

  final String? title;
  final String? subtitle;

  // End of the title row, e.g. a "3 selected" badge.
  final Widget? trailing;
  final Widget child;
  final EdgeInsets padding;

  static const double _handleWidth = 40;
  static const double _handleHeight = 4;
  static const double _handleAlpha = 0.4;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return SafeArea(
      top: false,
      child: Padding(
        padding: padding,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                margin: const EdgeInsets.only(top: 10, bottom: 16),
                width: _handleWidth,
                height: _handleHeight,
                decoration: BoxDecoration(
                  color: tokens.text2.withValues(alpha: _handleAlpha),
                  borderRadius: BorderRadius.circular(_handleHeight / 2),
                ),
              ),
            ),
            if (title != null) ...[
              Row(
                children: [
                  Expanded(child: Text(title!, style: text.titleLarge)),
                  if (trailing != null) trailing!,
                ],
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 4),
                Text(subtitle!, style: text.bodyMedium),
              ],
              const SizedBox(height: 16),
            ],
            Flexible(child: child),
          ],
        ),
      ),
    );
  }
}
