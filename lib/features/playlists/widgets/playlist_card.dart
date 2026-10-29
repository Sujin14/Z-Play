import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/widgets/cover_collage.dart';

enum _CardAction { rename, delete }

class PlaylistCard extends StatelessWidget {
  const PlaylistCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.coverSeeds,
    required this.size,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
  });

  final String name;
  final String subtitle;
  final List<String> coverSeeds;
  final double size;
  final VoidCallback onOpen;
  final VoidCallback onRename;
  final VoidCallback onDelete;

  static const double _menuInset = 4;
  static const double _menuDot = 36;
  static const double _menuDotAlpha = 0.35;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.album),
      onTap: onOpen,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox.square(
            dimension: size,
            child: Stack(
              children: [
                CoverCollage(
                  seeds: coverSeeds,
                  size: size,
                  radius: AppRadii.album,
                ),
                Positioned(
                  top: _menuInset,
                  right: _menuInset,
                  child: PopupMenuButton<_CardAction>(
                    tooltip: 'Playlist actions',
                    padding: EdgeInsets.zero,
                    onSelected: (action) => switch (action) {
                      _CardAction.rename => onRename(),
                      _CardAction.delete => onDelete(),
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(
                          value: _CardAction.rename, child: Text('Rename')),
                      PopupMenuItem(
                          value: _CardAction.delete, child: Text('Delete')),
                    ],
                    // The dot is smaller than the touch target around it.
                    child: SizedBox.square(
                      dimension: AppSizes.touchTarget,
                      child: Center(
                        child: Container(
                          width: _menuDot,
                          height: _menuDot,
                          decoration: BoxDecoration(
                            color:
                                Colors.black.withValues(alpha: _menuDotAlpha),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.more_vert,
                              size: AppSizes.icon, color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: text.titleMedium),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: text.bodyMedium,
          ),
        ],
      ),
    );
  }
}
