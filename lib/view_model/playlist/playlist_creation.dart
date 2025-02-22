import 'package:flutter/material.dart';
import '../providers/playlist_provider.dart';
import '../../model/model.dart';

/// **Displays a dialog to add a song to an existing playlist**
void showPlaylistDialog(BuildContext context, PlaylistProvider playlistProvider,
    MusicFile musicFile) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Add to Playlist'),
        content: SizedBox(
          width: double.maxFinite,
          height: 300,
          child: playlistProvider.playlists.isEmpty
              ? const Center(child: Text('No playlists available.'))
              : ListView.builder(
                  itemCount: playlistProvider.playlists.length,
                  itemBuilder: (context, index) {
                    final playlist = playlistProvider.playlists[index];

                    return Card(
                      color: Colors.grey.shade900,
                      child: ListTile(
                        trailing: const Icon(Icons.add, color: Colors.white),
                        title: Text(playlist.name,
                            style: const TextStyle(color: Colors.white)),
                        onTap: () {
                          _handleAddSongToPlaylist(
                              context, playlistProvider, playlist, musicFile);
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
              _showCreatePlaylistDialog(context, playlistProvider, musicFile);
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

/// **Handles Adding a Song to an Existing Playlist**
void _handleAddSongToPlaylist(BuildContext context,
    PlaylistProvider playlistProvider, Playlist playlist, MusicFile musicFile) {
  bool songExists = playlist.songs.any((song) => song.path == musicFile.path);

  String songTitle = musicFile.title.length > 20
      ? '${musicFile.title.substring(0, 20)}...'
      : musicFile.title;

  if (songExists) {
    _showSnackBar(context, '$songTitle already exists in "${playlist.name}"',
        Colors.orange);
  } else {
    playlistProvider.addSongToPlaylist(playlist, musicFile);
    _showSnackBar(
        context, '$songTitle added to "${playlist.name}"', Colors.green);
  }

  Navigator.pop(context); // Close the dialog after selection
}

/// **Displays a dialog to create a new playlist and add a song to it**
void _showCreatePlaylistDialog(BuildContext context,
    PlaylistProvider playlistProvider, MusicFile musicFile) {
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
              FocusScope.of(context)
                  .unfocus(); // Closes keyboard to prevent UI obstruction

              if (playlistName.isEmpty) {
                _showSnackBar(
                    context, 'Please enter a playlist name.', Colors.red);
                return;
              }

              bool playlistExists = playlistProvider.playlists
                  .any((playlist) => playlist.name == playlistName);

              if (playlistExists) {
                _showSnackBar(context,
                    'A playlist with this name already exists.', Colors.red);
                return;
              }

              final newPlaylist =
                  Playlist(name: playlistName, songs: [musicFile]);
              await playlistProvider.createPlaylist(newPlaylist);

              _showSnackBar(
                  context,
                  'Playlist "$playlistName" created and song added!',
                  Colors.green);
              Navigator.pop(context); // Close the dialog after creation
            },
            child: const Text('Create'),
          ),
        ],
      );
    },
  );
}

/// **Displays a SnackBar for User Feedback**
void _showSnackBar(BuildContext context, String message, Color color) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: const TextStyle(color: Colors.white)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 2),
    ),
  );
}
