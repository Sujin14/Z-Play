import 'package:flutter/material.dart';

import '../../../core/widgets/artist_avatar.dart';

class ArtistCard extends StatelessWidget {
  const ArtistCard({
    super.key,
    required this.name,
    required this.subtitle,
    required this.avatarSize,
    required this.onTap,
  });

  final String name;
  final String subtitle;
  final double avatarSize;
  final VoidCallback onTap;

  static const double _radius = 16;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return InkWell(
      customBorder:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(_radius)),
      onTap: onTap,
      child: Column(
        children: [
          ArtistAvatar(name: name, size: avatarSize),
          const SizedBox(height: 10),
          Text(
            name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: text.titleMedium,
          ),
          Text(subtitle, maxLines: 1, style: text.bodyMedium),
        ],
      ),
    );
  }
}
