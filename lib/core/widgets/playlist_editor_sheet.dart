import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/song_model.dart';
import '../models/user_playlist_model.dart';
import '../state/library_view_model.dart';
import '../state/playlist_view_model.dart';
import '../theme/app_radii.dart';
import '../theme/app_sizes.dart';
import '../theme/app_tokens.dart';
import 'app_sheet.dart';
import 'cover_art.dart';
import 'gradient_checkbox.dart';
import 'primary_button.dart';

// Creates a playlist, or edits one when playlist is given. initialSongs
// preselects songs, e.g. when saving the queue.
Future<void> showPlaylistEditor(
  BuildContext context, {
  UserPlaylist? playlist,
  List<Song> initialSongs = const [],
}) {
  return showAppSheet<void>(
    context,
    isScrollControlled: true,
    builder: (context) {
      return PlaylistEditorSheet(
          playlist: playlist, initialSongs: initialSongs);
    },
  );
}

class PlaylistEditorSheet extends StatefulWidget {
  const PlaylistEditorSheet(
      {super.key, required this.playlist, required this.initialSongs});

  final UserPlaylist? playlist;
  final List<Song> initialSongs;

  @override
  State<PlaylistEditorSheet> createState() => _PlaylistEditorSheetState();
}

class _PlaylistEditorSheetState extends State<PlaylistEditorSheet> {
  late final TextEditingController _name = TextEditingController(
    text: widget.playlist?.name ?? '',
  );
  late final Set<String> _selected = {
    for (final song in widget.playlist?.songs ?? widget.initialSongs) song.path,
  };
  String? _error;
  String _filter = '';

  static const double _heightFactor = 0.75;
  static const double _fieldRadius = 18;
  static const double _rowRadius = 14;
  static const double _focusedBorderWidth = 1.5;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final songs = context.watch<LibraryViewModel>().songs;
    final needle = _filter.trim().toLowerCase();
    // Display only; saving still works from the full list.
    final shown = needle.isEmpty
        ? songs
        : [
            for (final song in songs)
              if (song.title.toLowerCase().contains(needle) ||
                  song.artist.toLowerCase().contains(needle) ||
                  song.album.toLowerCase().contains(needle))
                song,
          ];
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * _heightFactor,
        child: AppSheet(
          title: widget.playlist == null ? 'New playlist' : 'Edit playlist',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
                color: tokens.chip,
                borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Text(
              '${_selected.length} selected',
              style: text.labelMedium?.copyWith(
                  color: tokens.accentText, fontWeight: FontWeight.w700),
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
          child: Column(
            children: [
              TextField(
                controller: _name,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: 'Name',
                  errorText: _error,
                  border: _fieldBorder(tokens.line),
                  enabledBorder: _fieldBorder(tokens.line),
                  focusedBorder: _fieldBorder(tokens.accentText,
                      width: _focusedBorderWidth),
                  errorBorder: _fieldBorder(tokens.heart),
                  focusedErrorBorder:
                      _fieldBorder(tokens.heart, width: _focusedBorderWidth),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                onChanged: (value) => setState(() => _filter = value),
                textInputAction: TextInputAction.search,
                decoration: const InputDecoration(
                  hintText: 'Search songs',
                  prefixIcon: Icon(Icons.search_rounded),
                ),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: shown.isEmpty
                    ? Center(
                        child: Text(
                          songs.isEmpty
                              ? 'No songs found on this device.'
                              : 'No songs match your search.',
                          style: text.bodyMedium,
                        ),
                      )
                    : ListView.builder(
                        itemCount: shown.length,
                        itemBuilder: (context, index) => _songRow(shown[index]),
                      ),
              ),
              const SizedBox(height: 12),
              PrimaryButton(
                label: 'Save playlist',
                expand: true,
                onPressed: () => _save(context, songs),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static OutlineInputBorder _fieldBorder(Color color, {double width = 1}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(_fieldRadius),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  Widget _songRow(Song song) {
    final text = Theme.of(context).textTheme;
    final checked = _selected.contains(song.path);
    return Semantics(
      checked: checked,
      child: InkWell(
        borderRadius: BorderRadius.circular(_rowRadius),
        onTap: () => setState(() {
          if (checked) {
            _selected.remove(song.path);
          } else {
            _selected.add(song.path);
          }
        }),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              GradientCheckbox(checked: checked),
              const SizedBox(width: 14),
              CoverArt(
                  seed: song.title,
                  size: AppSizes.smallCover,
                  radius: AppRadii.small),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(song.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.titleMedium),
                    Text(song.artist,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: text.bodySmall),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Songs hidden from the library (system sounds, short clips, hidden
  // folders) are not in the checklist, but a playlist that already holds them
  // keeps them on save.
  Future<void> _save(BuildContext context, List<Song> songs) async {
    final playlists = context.read<PlaylistViewModel>();
    final visiblePaths = {for (final song in songs) song.path};
    final keptHidden = [
      for (final song in widget.playlist?.songs ?? const <Song>[])
        if (!visiblePaths.contains(song.path) && _selected.contains(song.path))
          song,
    ];
    final chosen = [
      ...keptHidden,
      for (final song in songs)
        if (_selected.contains(song.path)) song,
    ];
    final error = widget.playlist == null
        ? await playlists.create(_name.text, chosen)
        : await playlists.update(
            originalName: widget.playlist!.name,
            name: _name.text,
            songs: chosen,
          );
    if (!context.mounted) return;
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    Navigator.pop(context);
  }
}
