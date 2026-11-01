import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';

class HiddenFolderRow extends StatelessWidget {
  const HiddenFolderRow({super.key, required this.path, required this.onShow});

  final String path;
  final VoidCallback onShow;

  static const double _radius = 20;
  static const _pathLines = 2;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 6, 12),
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(_radius),
        border: Border.all(color: tokens.line),
      ),
      child: Row(
        children: [
          Container(
            width: AppSizes.iconTile,
            height: AppSizes.iconTile,
            decoration: BoxDecoration(
              color: tokens.chip,
              borderRadius: BorderRadius.circular(AppRadii.small),
            ),
            child: Icon(Icons.folder_outlined,
                size: AppSizes.icon, color: tokens.accentText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              path,
              maxLines: _pathLines,
              overflow: TextOverflow.ellipsis,
              style: text.bodyMedium?.copyWith(color: tokens.text),
            ),
          ),
          IconButton(
            tooltip: 'Show folder',
            onPressed: onShow,
            icon: Icon(Icons.visibility_outlined, color: tokens.accentText),
          ),
        ],
      ),
    );
  }
}
