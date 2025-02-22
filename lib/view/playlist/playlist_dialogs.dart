import 'package:flutter/material.dart';
import 'package:musicplayer/model/model.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:musicplayer/view_model/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

/// **Shows a dialog to create or edit a playlist.**
/// - If `playlist` is `null`, a new playlist is created.
/// - Allows users to select songs for the playlist.
void showCreateOrEditPlaylistDialog({
  required BuildContext context,
  required PlaylistProvider playlistProvider,
  required MusicProvider musicProvider,
  Playlist? playlist,
}) {
  final TextEditingController nameController =
      TextEditingController(text: playlist?.name ?? '');
  final List<MusicFile> selectedSongs = [...?playlist?.songs];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text(playlist == null ? 'Create Playlist' : 'Edit Playlist'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Playlist Name Input Field
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Playlist Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 20),

                // Song Selection Header
                const Text(
                  'Select Songs:',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple),
                ),
                const SizedBox(height: 10),

                // Song Selection List
                _buildSongSelectionList(setState, musicProvider, selectedSongs),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty) {
                  _showErrorSnackbar(context, 'Please enter a playlist name');
                  return;
                }

                final existingPlaylist = playlistProvider.playlists.firstWhere(
                  (p) => p.name == nameController.text.trim(),
                  orElse: () => Playlist(name: '', songs: []),
                );

                if (existingPlaylist.name.isNotEmpty && playlist == null) {
                  _showErrorSnackbar(
                      context, 'A playlist with this name already exists');
                  return;
                }

                final updatedPlaylist =
                    playlist ?? Playlist(name: nameController.text, songs: []);
                updatedPlaylist.name = nameController.text;
                updatedPlaylist.songs = selectedSongs;

                if (playlist == null) {
                  playlistProvider.createPlaylist(updatedPlaylist);
                } else {
                  updatedPlaylist.save();
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

/// **Builds a song selection list for adding new songs to a playlist.**
Widget _buildSongSelectionList(StateSetter setState,
    MusicProvider musicProvider, List<MusicFile> selectedSongs) {
  return SizedBox(
    height: 300,
    width: double.maxFinite,
    child: ListView.builder(
      itemCount: musicProvider.musicFiles.length,
      itemBuilder: (context, index) {
        final song = musicProvider.musicFiles[index];
        final bool isAlreadyInPlaylist = selectedSongs.contains(song);

        return CheckboxListTile(
          title: Text(
            song.title,
            overflow: TextOverflow.ellipsis,
          ),
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
  );
}

/// **Shows a dialog to rename an existing playlist.**
void showEditPlaylistNameDialog(BuildContext context, Playlist playlist) {
  final TextEditingController controller =
      TextEditingController(text: playlist.name);
  final playlistProvider =
      Provider.of<PlaylistProvider>(context, listen: false);

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
              _showErrorSnackbar(context, 'Playlist name cannot be empty');
              return;
            }

            final existingPlaylist = playlistProvider.playlists.firstWhere(
              (p) => p.name == controller.text.trim() && p != playlist,
              orElse: () => Playlist(name: '', songs: []),
            );

            if (existingPlaylist.name.isNotEmpty) {
              _showErrorSnackbar(
                  context, 'A playlist with this name already exists');
              return;
            }

            playlist.name = controller.text.trim();
            playlist.save();
            playlistProvider.notifyListeners();
            Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    ),
  );
}

/// **Shows a dialog to add songs to an existing playlist.**
/// - Users can select new songs to be added.
/// - Allows removing previously added songs.
void showAddSongsToPlaylistDialog(BuildContext context, Playlist playlist) {
  final musicProvider = Provider.of<MusicProvider>(context, listen: false);
  final playlistProvider =
      Provider.of<PlaylistProvider>(context, listen: false);
  final List<MusicFile> selectedSongs = [...playlist.songs];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text('Add Songs to ${playlist.name}'),
          content:
              _buildSongSelectionList(setState, musicProvider, selectedSongs),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                playlist.songs = selectedSongs.toSet().toList();
                playlist.save();
                playlistProvider.notifyListeners();
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

/// **Displays a SnackBar with an error message.**
void _showErrorSnackbar(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      duration: const Duration(seconds: 1),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.only(top: 50.0, left: 10.0, right: 10.0),
    ),
  );
}
