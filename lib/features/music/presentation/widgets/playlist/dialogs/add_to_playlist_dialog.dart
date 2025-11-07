import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/themes.dart';
import '../../../../domain/entities/music_file_entity.dart';
import '../../../../domain/entities/playlist_entity.dart';
import '../../../viewmodels/music_viewmodel.dart';
import '../../../viewmodels/playlist_viewmodel.dart';
import '../helpers/show_snackbar.dart';
import 'create_edit_playlist_dialog.dart';

void showPlaylistDialog(
  BuildContext context,
  PlaylistViewModel playlistViewModel,
  MusicFileEntity musicFile,
) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: double.maxFinite,
          height: 340,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 12),
              Text('Add to Playlist',
                  style: style(fontSize: 18, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              Expanded(
                child: playlistViewModel.playlists.isEmpty
                    ? const Center(child: Text('No playlists available.'))
                    : ListView.builder(
                        itemCount: playlistViewModel.playlists.length,
                        itemBuilder: (context, index) {
                          final playlist = playlistViewModel.playlists[index];
                          return Card(
                            color: Colors.transparent,
                            child: ListTile(
                              trailing: Icon(Icons.add,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge!
                                      .color),
                              title: Text(playlist.name,
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .textTheme
                                          .bodyLarge!
                                          .color)),
                              onTap: () => _handleAddSongToPlaylist(context,
                                  playlistViewModel, playlist, musicFile),
                            ),
                          );
                        },
                      ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      showCreateOrEditPlaylistDialog(
                        context: context,
                        playlistViewModel: playlistViewModel,
                        musicViewModel:
                            Provider.of<MusicViewModel>(context, listen: false),
                      );
                    },
                    child: const Text('Create New Playlist'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );
}

void _handleAddSongToPlaylist(
  BuildContext context,
  PlaylistViewModel playlistViewModel,
  PlaylistEntity playlist,
  MusicFileEntity musicFile,
) {
  final theme = Theme.of(context);
  bool songExists = playlist.songs.any((song) => song.path == musicFile.path);
  String songTitle = musicFile.title.length > 20
      ? '${musicFile.title.substring(0, 20)}...'
      : musicFile.title;

  if (songExists) {
    showSnackBar(context, '$songTitle already exists in "${playlist.name}"',
        theme.colorScheme.error);
  } else {
    playlistViewModel.addSongToPlaylist(playlist, musicFile);
    showSnackBar(context, '$songTitle added to "${playlist.name}"',
        theme.colorScheme.primary);
  }
  Navigator.pop(context);
}
