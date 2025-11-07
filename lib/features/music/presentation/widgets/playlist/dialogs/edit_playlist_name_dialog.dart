import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../domain/entities/playlist_entity.dart';
import '../../../viewmodels/playlist_viewmodel.dart';
import '../helpers/show_snackbar.dart';

void showEditPlaylistNameDialog(BuildContext context, PlaylistEntity playlist) {
  final theme = Theme.of(context);
  final controller = TextEditingController(text: playlist.name);
  final playlistViewModel =
      Provider.of<PlaylistViewModel>(context, listen: false);

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.transparent,
      contentPadding: EdgeInsets.zero,
      content: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.02),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withOpacity(0.04)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Edit Playlist Name',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Playlist Name')),
            const SizedBox(height: 12),
            Row(mainAxisAlignment: MainAxisAlignment.end, children: [
              TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () {
                  final newName = controller.text.trim();
                  if (newName.isEmpty) {
                    showSnackBar(context, 'Playlist name cannot be empty',
                        theme.colorScheme.error);
                    return;
                  }
                  final exists = playlistViewModel.playlists
                      .any((p) => p.name == newName && p != playlist);
                  if (exists) {
                    showSnackBar(
                        context,
                        'A playlist with this name already exists',
                        theme.colorScheme.error);
                    return;
                  }
                  playlistViewModel.editPlaylistName(playlist, newName);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}
