import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class RankNumber extends StatelessWidget {
  const RankNumber({super.key, required this.rank, required this.highlighted});

  final int rank;
  final bool highlighted;

  static const double _width = 24;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    return SizedBox(
      width: _width,
      child: Text(
        '$rank',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: highlighted ? tokens.accentText : tokens.text2,
            ),
      ),
    );
  }
}
