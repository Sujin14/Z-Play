import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';

class FolderRow extends StatelessWidget {
  const FolderRow({
    super.key,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onHide,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onHide;

  static const double _radius = 20;
  static const double _iconTile = 48;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(_radius);
    return Material(
      color: tokens.card,
      shape: RoundedRectangleBorder(
          borderRadius: radius, side: BorderSide(color: tokens.line)),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 14, 6, 14),
          child: Row(
            children: [
              Container(
                width: _iconTile,
                height: _iconTile,
                decoration: BoxDecoration(
                  color: tokens.chip,
                  borderRadius: BorderRadius.circular(AppRadii.thumb),
                ),
                child: Icon(Icons.folder_outlined, color: tokens.accentText),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: text.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Hide folder',
                onPressed: onHide,
                icon: const Icon(Icons.visibility_off_outlined),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
