import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';
import 'package:provider/provider.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../viewmodels/music_viewmodel.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../domain/entities/music_file_entity.dart';

void showPlaylistDialog(
    BuildContext context, PlaylistViewModel playlistViewModel, MusicFileEntity musicFile) {
  final theme = Theme.of(context);
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add to Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: playlistViewModel.playlists.isEmpty
              ? const Center(child: Text('No playlists available.'))
              : ListView.builder(
                  itemCount: playlistViewModel.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlistViewModel.playlists[index];
                    return Card(
                      color: theme.colorScheme.surface,
                      child: ListTile(
                        trailing: Icon(Icons.add, color: theme.textTheme.bodyLarge!.color),
                        title: Text(playlist.name,
                            style: TextStyle(color: theme.textTheme.bodyLarge!.color)),
                        onTap: () {
                          _handleAddSongToPlaylist(context, playlistViewModel, playlist, musicFile);
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _showCreatePlaylistDialog(context, playlistViewModel, musicFile);
            },
            child: const Text('Create New Playlist'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      );
    },
  );
}

void _handleAddSongToPlaylist(BuildContext context, PlaylistViewModel playlistViewModel,
    PlaylistEntity playlist, MusicFileEntity musicFile) {
  final theme = Theme.of(context);
  bool songExists = playlist.songs.any((song) => song.path == musicFile.path);
  String songTitle = musicFile.title.length > 20
      ? '${musicFile.title.substring(0, 20)}...'
      : musicFile.title;

  if (songExists) {
    _showSnackBar(context, '$songTitle already exists in "${playlist.name}"', theme.colorScheme.editIcon);
  } else {
    playlistViewModel.addSongToPlaylist(playlist, musicFile);
    _showSnackBar(context, '$songTitle added to "${playlist.name}"', theme.colorScheme.trendingIcon);
  }
  Navigator.pop(context);
}

void _showCreatePlaylistDialog(
    BuildContext context, PlaylistViewModel playlistViewModel, MusicFileEntity musicFile) {
  final theme = Theme.of(context);
  final TextEditingController playlistNameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Enter Playlist Name'),
        content: TextField(
          controller: playlistNameController,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final playlistName = playlistNameController.text.trim();
              if (playlistName.isEmpty) {
                _showSnackBar(context, 'Please enter a playlist name.', theme.colorScheme.error);
                return;
              }
              bool playlistExists = playlistViewModel.playlists
                  .any((playlist) => playlist.name == playlistName);
              if (playlistExists) {
                _showSnackBar(
                    context, 'A playlist with this name already exists.', theme.colorScheme.error);
                return;
              }
              final newPlaylist = PlaylistEntity(name: playlistName, songs: []);
              await playlistViewModel.createNewPlaylist(newPlaylist);
              await playlistViewModel.addSongToPlaylist(newPlaylist, musicFile);
              _showSnackBar(
                  context, 'Playlist "$playlistName" created and song added!', theme.colorScheme.trendingIcon);
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}

void showEditPlaylistNameDialog(BuildContext context, PlaylistEntity playlist) {
  final theme = Theme.of(context);
  final TextEditingController controller = TextEditingController(text: playlist.name);
  final playlistViewModel = Provider.of<PlaylistViewModel>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Edit Playlist Name'),
      content: TextField(
        controller: controller,
        decoration: const InputDecoration(
          labelText: 'Playlist Name',
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (controller.text.trim().isEmpty) {
              _showSnackBar(context, 'Playlist name cannot be empty', theme.colorScheme.error);
              return;
            }
            final existingPlaylist = playlistViewModel.playlists.firstWhere(
              (p) => p.name == controller.text.trim() && p != playlist,
              orElse: () => PlaylistEntity(name: '', songs: []),
            );
            if (existingPlaylist.name.isNotEmpty) {
              _showSnackBar(context, 'A playlist with this name already exists', theme.colorScheme.error);
              return;
            }
            playlistViewModel.editPlaylistName(playlist, controller.text.trim());
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

void showAddSongsToPlaylistDialog(BuildContext context, PlaylistEntity playlist) {
  final musicViewModel = Provider.of<MusicViewModel>(context, listen: false);
  final playlistViewModel = Provider.of<PlaylistViewModel>(context, listen: false);
  final List<MusicFileEntity> selectedSongs = [...playlist.songs];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text('Add Songs to ${playlist.name}'),
          content: SizedBox(
            height: 300,
            width: double.maxFinite,
            child: ListView.builder(
              itemCount: musicViewModel.musicFiles.length,
              itemBuilder: (context, index) {
                final song = musicViewModel.musicFiles[index];
                final bool isAlreadyInPlaylist = selectedSongs.contains(song);
                return CheckboxListTile(
                  title: Text(song.title, overflow: TextOverflow.ellipsis),
                  value: isAlreadyInPlaylist,
                  onChanged: isAlreadyInPlaylist
                      ? null
                      : (value) => setState(() {
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
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                for (var song in selectedSongs) {
                  if (!playlist.songs.contains(song)) {
                    playlistViewModel.addSongToPlaylist(playlist, song);
                  }
                }
                Navigator.pop(context);
              },
              child: const Text('Add Songs'),
            ),
          ],
        );
      },
    ),
  );
}

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
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(playlist == null ? 'Create Playlist' : 'Edit Playlist'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Playlist Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  'Select Songs:',
                  style: TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold, color: theme.colorScheme.tertiary),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (nameController.text.trim().isEmpty) {
                  _showSnackBar(context, 'Please enter a playlist name', theme.colorScheme.error);
                  return;
                }
                final existingPlaylist = playlistViewModel.playlists.firstWhere(
                  (p) => p.name == nameController.text.trim() && p != playlist,
                  orElse: () => PlaylistEntity(name: '', songs: []),
                );
                if (existingPlaylist.name.isNotEmpty && playlist == null) {
                  _showSnackBar(context, 'A playlist with this name already exists', theme.colorScheme.error);
                  return;
                }
                final updatedPlaylist =
                    PlaylistEntity(name: nameController.text.trim(), songs: selectedSongs);
                if (playlist == null) {
                  await playlistViewModel.createNewPlaylist(updatedPlaylist);
                  for (var song in selectedSongs) {
                    await playlistViewModel.addSongToPlaylist(updatedPlaylist, song);
                  }
                } else {
                  await playlistViewModel.editPlaylistName(playlist, nameController.text.trim());
                  final currentSongs =
                      playlistViewModel.playlists.firstWhere((p) => p.name == updatedPlaylist.name).songs;
                  for (var song in currentSongs) {
                    if (!selectedSongs.contains(song)) {
                      await playlistViewModel.removeSongFromPlaylist(updatedPlaylist, song);
                    }
                  }
                  for (var song in selectedSongs) {
                    if (!currentSongs.contains(song)) {
                      await playlistViewModel.addSongToPlaylist(updatedPlaylist, song);
                    }
                  }
                }
                Navigator.pop(context);
              },
              child: Text(playlist == null ? 'Create' : 'Save'),
            ),
          ],
        );
      },
    ),
  );
}

void _showSnackBar(BuildContext context, String message, Color color) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: theme.textTheme.bodyLarge!.color)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 2),
    ),
  );
}