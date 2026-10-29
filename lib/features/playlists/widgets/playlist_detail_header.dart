import 'package:flutter/material.dart';

import '../../../core/widgets/collection_header.dart';
import '../../../core/widgets/cover_collage.dart';

class PlaylistDetailHeader extends StatelessWidget {
  const PlaylistDetailHeader({
    super.key,
    required this.title,
    required this.subtitle,
    required this.coverSeeds,
    required this.onPlayAll,
    required this.onShuffle,
  });

  final String title;
  final String subtitle;
  final List<String> coverSeeds;
  // Null disables the button, e.g. for an empty playlist.
  final VoidCallback? onPlayAll;
  final VoidCallback? onShuffle;

  @override
  Widget build(BuildContext context) {
    return CollectionHeader(
      cover: CoverCollage(
        seeds: coverSeeds,
        size: CollectionHeader.size,
        radius: CollectionHeader.radius,
      ),
      title: title,
      subtitle: subtitle,
      onPlayAll: onPlayAll,
      onShuffle: onShuffle,
    );
  }
}
