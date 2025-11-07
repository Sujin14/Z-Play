import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:musicplayer/constants/themes.dart';
import '../../../domain/entities/playlist_entity.dart';

class PlaylistSongTile extends StatelessWidget {
  final double hi;
  final dynamic song;
  final PlaylistEntity playlist;
  final bool isFavorite;
  final VoidCallback onPlay;
  final VoidCallback onDelete;
  final VoidCallback onFavoriteToggle;

  const PlaylistSongTile({
    super.key,
    required this.hi,
    required this.song,
    required this.playlist,
    required this.isFavorite,
    required this.onPlay,
    required this.onDelete,
    required this.onFavoriteToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: theme.colorScheme.glassFill,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: theme.colorScheme.glassBorder),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                height: hi / 14,
                width: hi / 14,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.18),
                      theme.colorScheme.tertiary.withOpacity(0.12),
                    ],
                  ),
                ),
                child: Icon(Icons.music_note, color: theme.colorScheme.musicIcon),
              ),
              title: SizedBox(
                height: hi / 25,
                width: double.infinity,
                child: Marquee(
                  text: song.title,
                  style: style(fontSize: hi / 50, fontWeight: FontWeight.bold),
                  scrollAxis: Axis.horizontal,
                  blankSpace: 10,
                  velocity: 30.0,
                  startPadding: 10.0,
                  accelerationDuration: const Duration(seconds: 5),
                ),
              ),
              onTap: onPlay,
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: Icon(Icons.delete, color: theme.colorScheme.error),
                    onPressed: onDelete,
                  ),
                  IconButton(
                    icon: Icon(
                      isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: isFavorite
                          ? theme.colorScheme.favoriteIconFilled
                          : theme.colorScheme.favoriteIconEmpty,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
