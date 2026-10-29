import 'package:flutter/material.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';

// Coral text is ~3.6:1 on the light gradient, so the message uses body text
// and the icon carries the color.
class PlayerErrorLine extends StatelessWidget {
  const PlayerErrorLine({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(Icons.warning_amber_rounded,
            size: AppSizes.iconSmall, color: AppTokens.of(context).heart),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTokens.of(context).text,
                ),
          ),
        ),
      ],
    );
  }
}
