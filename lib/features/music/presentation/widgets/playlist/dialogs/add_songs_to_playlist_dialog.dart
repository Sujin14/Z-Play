import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../../../constants/themes.dart';
import '../../../../domain/entities/music_file_entity.dart';
import '../../../../domain/entities/playlist_entity.dart';
import '../../../viewmodels/music_viewmodel.dart';
import '../../../viewmodels/playlist_viewmodel.dart';

void showAddSongsToPlaylistDialog(
    BuildContext context, PlaylistEntity playlist) {
  final musicViewModel = Provider.of<MusicViewModel>(context, listen: false);
  final playlistViewModel =
      Provider.of<PlaylistViewModel>(context, listen: false);
  final List<MusicFileEntity> selectedSongs = [...playlist.songs];

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(builder: (context, setState) {
      return AlertDialog(
        backgroundColor: Colors.transparent,
        contentPadding: EdgeInsets.zero,
        content: Container(
          padding: const EdgeInsets.all(12),
          width: double.maxFinite,
          height: 420,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.02),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withOpacity(0.04)),
          ),
          child: Column(
            children: [
              Text('Add Songs to ${playlist.name}',
                  style: style(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: musicViewModel.musicFiles.length,
                  itemBuilder: (context, index) {
                    final song = musicViewModel.musicFiles[index];
                    final bool isSelected = selectedSongs.contains(song);
                    return CheckboxListTile(
                      title: Text(song.title, overflow: TextOverflow.ellipsis),
                      value: isSelected,
                      onChanged: (value) => setState(() {
                        if (value == true)
                          selectedSongs.add(song);
                        else
                          selectedSongs.remove(song);
                      }),
                    );
                  },
                ),
              ),
              Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () {
                    for (var song in selectedSongs) {
                      if (!playlist.songs.contains(song))
                        playlistViewModel.addSongToPlaylist(playlist, song);
                    }
                    Navigator.pop(context);
                  },
                  child: const Text('Add Songs'),
                ),
              ]),
            ],
          ),
        ),
      );
    }),
  );
}
