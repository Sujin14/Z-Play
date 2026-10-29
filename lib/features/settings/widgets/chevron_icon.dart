import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class ChevronIcon extends StatelessWidget {
  const ChevronIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.chevron_right_rounded,
        color: AppTokens.of(context).text2);
  }
}
