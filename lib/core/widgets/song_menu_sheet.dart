import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../services/song_actions.dart';
import '../state/library_view_model.dart';
import '../state/player_view_model.dart';
import '../theme/app_radii.dart';
import '../theme/app_sizes.dart';
import '../theme/app_tokens.dart';
import 'app_sheet.dart';
import 'cover_art.dart';
import 'snack_pill.dart';

// "Remove from playlist" only shows when onRemove is given (playlist detail).
Future<void> showSongMenu(
  BuildContext context,
  Song song, {
  VoidCallback? onRemove,
}) {
  return showAppSheet<void>(
    context,
    builder: (_) =>
        SongMenuSheet(song: song, hostContext: context, onRemove: onRemove),
  );
}

class SongMenuSheet extends StatelessWidget {
  const SongMenuSheet({
    super.key,
    required this.song,
    required this.hostContext,
    this.onRemove,
  });

  final Song song;

  // Context of the screen that opened the menu; actions that show their own
  // sheet or snackbar run against it after this sheet closes.
  final BuildContext hostContext;
  final VoidCallback? onRemove;

  static const double _coverSize = 52;
  static const double _titleSize = 17;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final favorite = context.watch<LibraryViewModel>().isFavorite(song);

    void run(void Function() action) {
      Navigator.pop(context);
      action();
    }

    return AppSheet(
      padding: const EdgeInsets.only(bottom: 12),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              child: Row(
                children: [
                  CoverArt(seed: song.title, size: _coverSize),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          song.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style:
                              text.titleMedium?.copyWith(fontSize: _titleSize),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          song.subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: text.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Divider(color: tokens.line),
            const SizedBox(height: 6),
            _MenuItem(
              icon: Icons.playlist_play_rounded,
              label: 'Play next',
              onTap: () => run(() {
                hostContext.read<PlayerViewModel>().playNext(song);
                showSnackPill(hostContext, 'Will play next',
                    icon: Icons.playlist_play_rounded);
              }),
            ),
            _MenuItem(
              icon: Icons.queue_music_rounded,
              label: 'Add to queue',
              onTap: () => run(() {
                hostContext.read<PlayerViewModel>().addToQueue(song);
                showSnackPill(hostContext, 'Added to the queue',
                    icon: Icons.queue_music_rounded);
              }),
            ),
            _MenuItem(
              icon: Icons.playlist_add_rounded,
              label: 'Add to playlist',
              onTap: () => run(() => addToPlaylist(hostContext, song)),
            ),
            _MenuItem(
              icon: favorite
                  ? Icons.favorite_rounded
                  : Icons.favorite_border_rounded,
              label: favorite ? 'Remove from favorites' : 'Add to favorites',
              onTap: () => run(() => toggleFavorite(hostContext, song)),
            ),
            if (onRemove != null)
              _MenuItem(
                icon: Icons.delete_outline_rounded,
                label: 'Remove from playlist',
                destructive: true,
                onTap: () => run(onRemove!),
              ),
          ],
        ),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
    this.destructive = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool destructive;

  static const double _destructiveTintAlpha = 0.14;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final color = destructive ? tokens.heart : tokens.text;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: Row(
          children: [
            Container(
              width: AppSizes.iconTile,
              height: AppSizes.iconTile,
              decoration: BoxDecoration(
                color: destructive
                    ? tokens.heart.withValues(alpha: _destructiveTintAlpha)
                    : tokens.chip,
                borderRadius: BorderRadius.circular(AppRadii.small),
              ),
              child: Icon(icon,
                  size: AppSizes.icon,
                  color: destructive ? tokens.heart : tokens.accentText),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                label,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
