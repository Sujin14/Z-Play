import 'package:flutter/material.dart';
import '../../../domain/entities/playlist_entity.dart';
import 'playlist_card.dart';

class PlaylistGrid extends StatelessWidget {
  final List<PlaylistEntity> playlists;
  const PlaylistGrid({super.key, required this.playlists});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.78,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: playlists.length,
      itemBuilder: (_, index) => PlaylistCard(playlist: playlists[index]),
    );
  }
}
