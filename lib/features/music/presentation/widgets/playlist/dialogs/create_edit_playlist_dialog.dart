import 'package:flutter/material.dart';
import '../../../../../../constants/themes.dart';
import '../../../../domain/entities/music_file_entity.dart';
import '../../../../domain/entities/playlist_entity.dart';
import '../../../viewmodels/music_viewmodel.dart';
import '../../../viewmodels/playlist_viewmodel.dart';
import '../helpers/show_snackbar.dart';

void showCreateOrEditPlaylistDialog({
  required BuildContext context,
  required PlaylistViewModel playlistViewModel,
  required MusicViewModel musicViewModel,
  PlaylistEntity? playlist,
}) {
  final theme = Theme.of(context);
  final TextEditingController nameController =
      TextEditingController(text: playlist?.name ?? '');
  final List<MusicFileEntity> selectedSongs = [...?playlist?.songs];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(12),
          width: double.maxFinite,
          height: 520,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  playlist == null ? 'Create Playlist' : 'Edit Playlist',
                  style: style(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Playlist Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Select Songs:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.tertiary,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 300,
                  width: double.maxFinite,
                  child: ListView.builder(
                    itemCount: musicViewModel.musicFiles.length,
                    itemBuilder: (context, index) {
                      final song = musicViewModel.musicFiles[index];
                      final bool isSelected = selectedSongs.contains(song);
                      return CheckboxListTile(
                        title: Text(song.title, overflow: TextOverflow.ellipsis),
                        value: isSelected,
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            selectedSongs.add(song);
                          } else {
                            selectedSongs.remove(song);
                          }
                        }),
                      );
                    },
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final playlistName = nameController.text.trim();
                        if (playlistName.isEmpty) {
                          showSnackBar(
                            context,
                            'Please enter a playlist name',
                            theme.colorScheme.error,
                          );
                          return;
                        }

                        final exists = playlistViewModel.playlists.any(
                          (p) =>
                              p.name == playlistName &&
                              (playlist == null || p.name != playlist.name),
                        );

                        if (exists) {
                          showSnackBar(
                            context,
                            'A playlist with this name already exists',
                            theme.colorScheme.error,
                          );
                          return;
                        }

                        if (playlist == null) {
                          final newPlaylist =
                              PlaylistEntity(name: playlistName, songs: []);
                          await playlistViewModel.createNewPlaylist(newPlaylist);
                          for (var song in selectedSongs) {
                            await playlistViewModel.addSongToPlaylist(
                                newPlaylist, song);
                          }
                          showSnackBar(
                            context,
                            'Playlist "$playlistName" created!',
                            theme.colorScheme.primary,
                          );
                        } else {
                          // --- EDIT EXISTING ---
                          await playlistViewModel.editPlaylistName(
                              playlist, playlistName);

                          final existingPlaylist =
                              playlistViewModel.playlists.firstWhere(
                            (p) => p.name == playlistName,
                            orElse: () => playlist,
                          );

                          final currentSongs = existingPlaylist.songs;

                          // Remove unselected songs
                          for (var song in currentSongs) {
                            if (!selectedSongs.contains(song)) {
                              await playlistViewModel.removeSongFromPlaylist(
                                  existingPlaylist, song);
                            }
                          }

                          // Add new selections
                          for (var song in selectedSongs) {
                            if (!currentSongs.contains(song)) {
                              await playlistViewModel.addSongToPlaylist(
                                  existingPlaylist, song);
                            }
                          }

                          showSnackBar(
                            context,
                            'Playlist "$playlistName" updated!',
                            theme.colorScheme.primary,
                          );
                        }

                        Navigator.pop(context);
                      },
                      child: Text(playlist == null ? 'Create' : 'Save'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }),
  );
}
