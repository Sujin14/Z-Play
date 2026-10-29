import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../navigation/app_router.dart';
import '../navigation/navigation_service.dart';
import '../state/library_view_model.dart';
import '../state/player_view_model.dart';
import '../state/playlist_view_model.dart';
import '../widgets/add_to_playlist_sheet.dart';
import '../widgets/app_sheet.dart';
import '../widgets/playlist_editor_sheet.dart';
import '../widgets/snack_pill.dart';

Future<void> playFromList(
    BuildContext context, List<Song> songs, int index) async {
  if (index < 0 || index >= songs.length) return;
  final player = context.read<PlayerViewModel>();
  final started = await player.play(songs[index], queue: songs, index: index);
  if (!context.mounted) return;
  if (!started) {
    _error(context, player.error ?? 'Cannot play this song.');
    return;
  }
  await NavigationService.pushNamed(AppRoutes.player);
}

// Same as tapping the first row, so Now Playing opens too.
Future<void> playAll(BuildContext context, List<Song> songs) {
  return playFromList(context, songs, 0);
}

// Starts from a random song because turning shuffle on keeps the current
// song first; starting at index 0 would always open with track 1.
Future<void> shuffleAll(BuildContext context, List<Song> songs) async {
  if (songs.isEmpty) return;
  final player = context.read<PlayerViewModel>();
  final index = Random().nextInt(songs.length);
  final started = await player.play(songs[index], queue: songs, index: index);
  if (!context.mounted) return;
  if (!started) {
    _error(context, player.error ?? 'Cannot play this song.');
    return;
  }
  if (!player.shuffling) player.toggleShuffle();
  await NavigationService.pushNamed(AppRoutes.player);
}

Future<void> toggleFavorite(BuildContext context, Song song) async {
  final added = await context.read<LibraryViewModel>().toggleFavorite(song);
  if (!context.mounted) return;
  showSnackPill(
    context,
    added ? 'Added to Favorites' : 'Removed from Favorites',
    icon: added ? Icons.favorite_rounded : Icons.heart_broken_outlined,
  );
}

// With no playlists yet there is nothing to pick from, so this goes straight
// to the editor with the song preselected.
Future<void> addToPlaylist(BuildContext context, Song song) async {
  final playlists = context.read<PlaylistViewModel>();
  if (playlists.playlists.isEmpty) {
    await showPlaylistEditor(context, initialSongs: [song]);
    return;
  }
  if (!context.mounted) return;
  await showAppSheet<void>(
    context,
    isScrollControlled: true,
    builder: (sheetContext) =>
        AddToPlaylistSheet(song: song, hostContext: context),
  );
}

void _error(BuildContext context, String text) {
  showSnackPill(context, text, icon: Icons.warning_amber_rounded, error: true);
}
