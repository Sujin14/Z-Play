import 'package:flutter/material.dart';

import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_tokens.dart';
import 'sort_button.dart';

class LibraryCountRow extends StatelessWidget {
  const LibraryCountRow({
    super.key,
    required this.count,
    required this.sortLabel,
    required this.onSort,
  });

  final String count;
  // No sort button when null.
  final String? sortLabel;
  final VoidCallback onSort;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.screen, 12, 8, 4),
      child: SizedBox(
        height: AppSizes.touchTarget,
        child: Row(
          children: [
            Expanded(
              child: Text(
                count,
                style: text.bodyLarge
                    ?.copyWith(color: AppTokens.of(context).text2),
              ),
            ),
            if (sortLabel != null) SortButton(label: sortLabel!, onTap: onSort),
          ],
        ),
      ),
    );
  }
}
