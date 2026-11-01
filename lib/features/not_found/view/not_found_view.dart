import 'package:flutter/material.dart';

import '../../../core/app/app_name.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/empty_state.dart';
import '../../../core/widgets/gradient_scaffold.dart';

class NotFoundView extends StatelessWidget {
  const NotFoundView({super.key, required this.routeName});

  final String? routeName;

  static const double _codeSize = 64;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return GradientScaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screen, 16, AppSpacing.screen, 0),
              child: Text(appName.toUpperCase(), style: text.labelSmall),
            ),
            Expanded(
              child: EmptyState(
                icon: Icons.help_outline_rounded,
                badge: Text(
                  '404',
                  style: text.headlineLarge?.copyWith(
                    fontSize: _codeSize,
                    height: 1,
                    color: AppTokens.of(context).accentText,
                  ),
                ),
                title: 'Page not found',
                message: 'There is no page for ${routeName ?? 'this address'}.',
                actionLabel: 'Back to library',
                onAction: NavigationService.backToMain,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
