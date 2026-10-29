import 'package:flutter/material.dart';

import '../../../core/theme/app_tokens.dart';

class SettingsSectionLabel extends StatelessWidget {
  const SettingsSectionLabel(this.label, {super.key, this.trailing});

  final String label;
  // e.g. the hidden-folder count chip.
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: AppTokens.of(context).text2),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}
