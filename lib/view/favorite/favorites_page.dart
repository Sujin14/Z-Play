import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:musicplayer/model/model.dart';
import 'package:musicplayer/view/player/player_page.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:musicplayer/view_model/playlist/playlist_creation.dart';
import 'package:musicplayer/view_model/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

/// FavoritesPage Widget
/// - Displays a list of favorite music files.
/// - Allows users to play the song, add to playlists, or remove from favorites.
class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final musicProvider = Provider.of<MusicProvider>(context);
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Favorites',
            style: TextStyle(fontSize: hi / 45, color: Colors.white)),
      ),
      body: musicProvider.favorites.isEmpty
          ? const Center(
              child: Text(
                'No favorite songs yet!',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: musicProvider.favorites.length,
              itemBuilder: (context, index) {
                final favoriteMusicFile = musicProvider.favorites[index];

                return _buildFavoriteTile(context, hi, playlistProvider,
                    musicProvider, favoriteMusicFile);
              },
            ),
    );
  }

  /// Builds a ListTile for each favorite song.
  Widget _buildFavoriteTile(
      BuildContext context,
      double hi,
      PlaylistProvider playlistProvider,
      MusicProvider musicProvider,
      MusicFile favoriteMusicFile) {
    return Card(
      color: const Color.fromARGB(255, 101, 97, 119),
      child: ListTile(
        leading: const Icon(Icons.music_note, color: Colors.blue),
        title: SizedBox(
          height: hi / 25,
          width: double.infinity,
          child: Marquee(
            text: favoriteMusicFile.title,
            style: TextStyle(
              color: Colors.white,
              fontSize: hi / 50,
              fontWeight: FontWeight.bold,
            ),
            scrollAxis: Axis.horizontal,
            crossAxisAlignment: CrossAxisAlignment.start,
            blankSpace: 10,
            velocity: 30.0,
            startPadding: 10.0,
            accelerationDuration: Duration(seconds: 5),
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Playlist Add Button
            IconButton(
              icon: const Icon(Icons.playlist_add, color: Colors.white),
              onPressed: () {
                showPlaylistDialog(
                    context, playlistProvider, favoriteMusicFile);
              },
            ),
            // Remove from Favorites Button
            IconButton(
              icon: const Icon(Icons.favorite, color: Colors.red),
              onPressed: () {
                musicProvider.toggleFavorite(favoriteMusicFile);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    behavior: SnackBarBehavior.floating,
                    margin: const EdgeInsets.all(10),
                    backgroundColor: Colors.red,
                    content: Text(
                      '${favoriteMusicFile.title.length > 10 ? 
                      '${favoriteMusicFile.title.substring(0, 10)}...':
                       favoriteMusicFile.title} removed from Favorites',
                    ),
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
            ),
          ],
        ),
        // On Tap: Navigate to Music Player
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MusicPlayer(
                musicFile: favoriteMusicFile,
                playlist: musicProvider.favorites,
              ),
            ),
          );
        },
      ),
    );
  }
}
