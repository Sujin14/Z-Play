import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:musicplayer/view/player/player_page.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:musicplayer/view_model/playlist/playlist_creation.dart';
import 'package:musicplayer/view_model/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class RecentlyPlayedPage extends StatelessWidget {
  const RecentlyPlayedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context);
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    final hi = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text('Recently Played', style: TextStyle(fontSize: hi / 50)),
      ),
      body: musicProvider.recentlyPlayed.isEmpty
          ? const Center(
              child: Text(
                'No recently played songs',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            )
          : ListView.builder(
              itemCount: musicProvider.recentlyPlayed.length,
              itemBuilder: (context, index) {
                final musicFile = musicProvider.recentlyPlayed[index];

                return Card(
                  color: const Color.fromARGB(255, 101, 97, 119),
                  child: ListTile(
                    leading: const Icon(
                      Icons.music_note,
                      color: Colors.blue,
                    ),
                    title: SizedBox(
                      height: hi / 25,
                      width: double.infinity,
                      child: Marquee(
                        text: musicFile.title,
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
                        IconButton(
                          icon: const Icon(Icons.playlist_add,
                              color: Colors.white),
                          onPressed: () {
                            showPlaylistDialog(
                                context, playlistProvider, musicFile);
                          },
                        ),
                        // Favorite Button
                        IconButton(
                          icon: Icon(
                            musicProvider.isFavorite(musicFile)
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: musicProvider.isFavorite(musicFile)
                                ? Colors.red
                                : Colors.grey,
                          ),
                          onPressed: () {
                            musicProvider.toggleFavorite(musicFile);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                behavior: SnackBarBehavior.floating,
                                margin: const EdgeInsets.all(10),
                                backgroundColor: Colors.red,
                                content: Text(
                                  musicProvider.isFavorite(musicFile)
                                      ? '${musicFile.title.length > 25 ? '${musicFile.title.substring(0, 25)}...' : musicFile.title} added to Favorites'
                                      : '${musicFile.title.length > 25 ? '${musicFile.title.substring(0, 25)}...' : musicFile.title} removed from Favorites',
                                ),
                                duration: const Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MusicPlayer(
                            musicFile: musicFile,
                            playlist: musicProvider.recentlyPlayed,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
