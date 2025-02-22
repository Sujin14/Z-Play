import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:musicplayer/model/model.dart';
import 'package:musicplayer/view/player/player_page.dart';
import 'package:musicplayer/view/playlist/playlist_dialogs.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:musicplayer/view_model/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

/// **Playlist Detail Screen**
/// - Displays all songs in the selected playlist.
/// - Allows users to **play songs**, **add new songs**, **remove songs**, and **mark songs as favorites**.
class PlaylistDetailScreen extends StatelessWidget {
  final Playlist playlist;

  const PlaylistDetailScreen({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final playlistProvider = Provider.of<PlaylistProvider>(context);
    final musicProvider = Provider.of<MusicProvider>(context);
    final double hi = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: _buildAppBar(context),
      body: _buildSongListView(context, playlistProvider, musicProvider, hi),
    );
  }

  /// **App Bar**
  /// - Displays the playlist name.
  /// - Provides an option to **add new songs** to the playlist.
  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: Text(playlist.name),
      actions: [
        IconButton(
          icon: const Icon(Icons.add),
          onPressed: () => showAddSongsToPlaylistDialog(context, playlist),
        ),
      ],
    );
  }

  /// **Song ListView**
  /// - Dynamically builds a list of songs in the playlist.
  /// - Each song has **play, favorite, and delete options**.
  Widget _buildSongListView(
    BuildContext context,
    PlaylistProvider playlistProvider,
    MusicProvider musicProvider,
    double hi,
  ) {
    return ListView.builder(
      itemCount: playlist.songs.length,
      itemBuilder: (context, index) {
        final musicFile = playlist.songs[index];
        return _buildSongTile(
            context, playlistProvider, musicProvider, musicFile, hi);
      },
    );
  }

  /// **Song Tile (Card)**
  /// - Displays song title with **marquee effect** for long names.
  /// - Provides **favorite** and **delete** options.
  /// - Navigates to **MusicPlayer** when tapped.
  Widget _buildSongTile(
    BuildContext context,
    PlaylistProvider playlistProvider,
    MusicProvider musicProvider,
    MusicFile musicFile,
    double hi,
  ) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Card(
        color: const Color.fromARGB(255, 101, 97, 119),
        child: ListTile(
          leading: const Icon(Icons.music_note, color: Colors.blue),
          title: _buildMarqueeText(musicFile, hi),
          trailing: _buildTrailingIcons(
              context, playlistProvider, musicProvider, musicFile),
          onTap: () => _playMusic(context, musicFile),
        ),
      ),
    );
  }

  /// **Marquee Text (Scrolling Song Title)**
  Widget _buildMarqueeText(MusicFile musicFile, double hi) {
    return SizedBox(
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
        accelerationDuration: const Duration(seconds: 5),
      ),
    );
  }

  /// **Trailing Icons (Favorite & Delete)**
  /// - Allows users to **favorite/unfavorite** a song.
  /// - Provides a delete option to remove the song from the playlist.
  Widget _buildTrailingIcons(
    BuildContext context,
    PlaylistProvider playlistProvider,
    MusicProvider musicProvider,
    MusicFile musicFile,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildFavoriteIcon(context, musicProvider, musicFile),
        _buildDeleteIcon(context, playlistProvider, musicFile),
      ],
    );
  }

  /// **Favorite Icon**
  /// - Toggles favorite status and shows a **SnackBar notification**.
  Widget _buildFavoriteIcon(
      BuildContext context, MusicProvider musicProvider, MusicFile musicFile) {
    return IconButton(
      icon: Icon(
        musicProvider.isFavorite(musicFile)
            ? Icons.favorite
            : Icons.favorite_border,
        color: musicProvider.isFavorite(musicFile) ? Colors.red : Colors.grey,
      ),
      onPressed: () {
        musicProvider.toggleFavorite(musicFile);
        _showFavoriteSnackBar(context, musicProvider, musicFile);
      },
    );
  }

  /// **Delete Icon**
  /// - Removes a song from the playlist and shows a **SnackBar notification**.
  Widget _buildDeleteIcon(BuildContext context,
      PlaylistProvider playlistProvider, MusicFile musicFile) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () {
        playlistProvider.removeSongFromPlaylist(playlist, musicFile);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Removed ${musicFile.title}')),
        );
      },
    );
  }

  /// **Show SnackBar for Favorite Action**
  void _showFavoriteSnackBar(
      BuildContext context, MusicProvider musicProvider, MusicFile musicFile) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
        backgroundColor: Colors.red,
        content: Text(
          style: TextStyle(color: Colors.white),
          musicProvider.isFavorite(musicFile)
              ? '${musicFile.title.length > 25 ? '${musicFile.title.substring(0, 25)}...' : musicFile.title} added to Favorites'
              : '${musicFile.title.length > 25 ? '${musicFile.title.substring(0, 25)}...' : musicFile.title} removed from Favorites',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  /// **Navigate to MusicPlayer**
  /// - Opens the `MusicPlayer` screen to play the selected song.
  void _playMusic(BuildContext context, MusicFile musicFile) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MusicPlayer(
          musicFile: musicFile,
          playlist: playlist.songs,
        ),
      ),
    );
  }
}
