import 'package:flutter/material.dart';

import '../../../core/models/collection_kind_model.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/album_cover.dart';
import '../../../core/widgets/artist_avatar.dart';
import '../../../core/widgets/collection_header.dart';
import '../../../core/widgets/cover_art.dart';

class CollectionCover extends StatelessWidget {
  const CollectionCover({super.key, required this.kind, required this.title});

  final CollectionKind kind;
  final String title;

  static const double _size = CollectionHeader.size;
  static const double _folderIconScale = 0.4;
  static const double _folderIconAlpha = 0.7;

  @override
  Widget build(BuildContext context) {
    return switch (kind) {
      CollectionKind.album =>
        AlbumCover(seed: title, size: _size, radius: CollectionHeader.radius),
      CollectionKind.artist => ArtistAvatar(name: title, size: _size),
      CollectionKind.folder => CoverArt(
          seed: title,
          size: _size,
          radius: CollectionHeader.radius,
          child: Icon(
            Icons.folder_outlined,
            size: _size * _folderIconScale,
            color: AppColors.onAccent.withValues(alpha: _folderIconAlpha),
          ),
        ),
    };
  }
}
