import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../models/user_playlist_model.dart';
import '../state/playlist_view_model.dart';
import '../theme/app_radii.dart';
import '../theme/app_sizes.dart';
import '../theme/app_tokens.dart';
import 'add_to_playlist_row.dart';
import 'app_sheet.dart';
import 'cover_collage.dart';
import 'dashed_box.dart';
import 'gradient_checkbox.dart';
import 'playlist_editor_sheet.dart';
import 'snack_pill.dart';

class AddToPlaylistSheet extends StatelessWidget {
  const AddToPlaylistSheet(
      {super.key, required this.song, required this.hostContext});

  final Song song;

  // Screen that opened the sheet; the snackbar shows there after it closes.
  final BuildContext hostContext;

  static const double _maxHeightFactor = 0.75;

  @override
  Widget build(BuildContext context) {
    final playlists = context.watch<PlaylistViewModel>();
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return ConstrainedBox(
      constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * _maxHeightFactor),
      child: AppSheet(
        title: 'Add to playlist',
        subtitle: song.title,
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: ListView(
          shrinkWrap: true,
          children: [
            AddToPlaylistRow(
              leading: DashedBox(
                color: tokens.accentText,
                radius: AppRadii.small,
                child: SizedBox.square(
                  dimension: AppSizes.smallCover,
                  child: Icon(Icons.add_rounded, color: tokens.accentText),
                ),
              ),
              title: Text(
                'New playlist',
                style: text.titleMedium?.copyWith(color: tokens.accentText),
              ),
              onTap: () {
                Navigator.pop(context);
                showPlaylistEditor(hostContext, initialSongs: [song]);
              },
            ),
            for (final playlist in playlists.playlists)
              _playlistRow(context, playlists, playlist),
          ],
        ),
      ),
    );
  }

  Widget _playlistRow(BuildContext context, PlaylistViewModel playlists,
      UserPlaylist playlist) {
    final text = Theme.of(context).textTheme;
    // Same check PlaylistViewModel.addSong uses to refuse duplicates.
    final added = playlist.songs.any((item) => item.path == song.path);
    final count =
        '${playlist.songs.length} ${playlist.songs.length == 1 ? 'track' : 'tracks'}';
    return AddToPlaylistRow(
      leading: CoverCollage(
          seeds: playlist.coverSeeds,
          size: AppSizes.smallCover,
          radius: AppRadii.small),
      title: Text(playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: text.titleMedium),
      subtitle:
          Text(added ? '$count · already added' : count, style: text.bodySmall),
      trailing: GradientCheckbox(checked: added),
      onTap: () async {
        final error = await playlists.addSong(playlist.name, song);
        if (!context.mounted) return;
        Navigator.pop(context);
        if (!hostContext.mounted) return;
        if (error != null) {
          showSnackPill(hostContext, error, icon: Icons.info_outline_rounded);
        } else {
          showSnackPill(hostContext, 'Added to "${playlist.name}"');
        }
      },
    );
  }
}
