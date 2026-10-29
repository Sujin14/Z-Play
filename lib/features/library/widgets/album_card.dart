import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/widgets/album_cover.dart';

class AlbumCard extends StatelessWidget {
  const AlbumCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.coverSize,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final double coverSize;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.album),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AlbumCover(seed: title, size: coverSize),
          const SizedBox(height: 10),
          Text(title,
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
