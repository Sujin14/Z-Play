import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';
import 'package:musicplayer/model/model.dart';
import 'package:musicplayer/view/playlist/playlist_details_page.dart';
import 'package:musicplayer/view/playlist/playlist_dialogs.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:musicplayer/view_model/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class PlaylistScreen extends StatelessWidget {
  const PlaylistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final double hi = MediaQuery.of(context).size.height;
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return Scaffold(
      appBar: _buildAppBar(hi),
      body: _buildPlaylistGrid(context, playlistProvider, hi),
      floatingActionButton: _buildFloatingActionButton(context, hi),
    );
  }

  AppBar _buildAppBar(double hi) {
    return AppBar(
      title: Text('Your Playlists', style: TextStyle(fontSize: hi / 45)),
    );
  }

  Widget _buildFloatingActionButton(BuildContext context, double hi) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 13),
      child: FloatingActionButton.extended(
        label: Text("Add New Playlist",
            style: TextStyle(color: Colors.white, fontSize: hi / 60)),
        onPressed: () => _showCreatePlaylistDialog(context),
      ),
    );
  }

  Widget _buildPlaylistGrid(
      BuildContext context, PlaylistProvider playlistProvider, double hi) {
    if (playlistProvider.playlists.isEmpty) {
      return const Center(
        child: Text(
          'No playlists available.',
          style: TextStyle(fontSize: 18, color: Colors.grey),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio:
              (MediaQuery.of(context).size.width / 2) / (hi / 3.5),
        ),
        itemCount: playlistProvider.playlists.length,
        itemBuilder: (context, index) {
          final playlist = playlistProvider.playlists[index];
          return PlaylistCard(playlist: playlist);
        },
      ),
    );
  }

  void _showCreatePlaylistDialog(BuildContext context) {
    final musicProvider = Provider.of<MusicProvider>(context, listen: false);
    final playlistProvider =
        Provider.of<PlaylistProvider>(context, listen: false);
    showCreateOrEditPlaylistDialog(
      context: context,
      playlistProvider: playlistProvider,
      musicProvider: musicProvider,
    );
  }
}

class PlaylistCard extends StatelessWidget {
  final Playlist playlist;

  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final double hi = MediaQuery.of(context).size.height;
    final playlistProvider = Provider.of<PlaylistProvider>(context);

    return GestureDetector(
      onTap: () => _navigateToPlaylistDetail(context, playlist),
      child: Card(
        elevation: 4,
        child: SizedBox(
          height: hi / 3.2,
          child: GridTile(
            header: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const AlbumArtWidget(),
            ),
            footer: Padding(
              padding: const EdgeInsets.all(10),
              child: _buildPlaylistInfo(context, hi, playlistProvider),
            ),
            child: Container(),
          ),
        ),
      ),
    );
  }

  void _navigateToPlaylistDetail(BuildContext context, Playlist playlist) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlaylistDetailScreen(playlist: playlist),
      ),
    );
  }

  Widget _buildPlaylistInfo(
      BuildContext context, double hi, PlaylistProvider playlistProvider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Text(
                playlist.name.toUpperCase(),
                overflow: TextOverflow.ellipsis,
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: hi / 50),
              ),
              Text(
                '${playlist.songs.length} songs',
                style: TextStyle(fontSize: hi / 60, color: Colors.grey),
              ),
            ],
          ),
        ),
        _buildEditButton(context, hi),
        _buildDeleteButton(context, hi, playlistProvider),
      ],
    );
  }

  Widget _buildEditButton(BuildContext context, double hi) {
    return IconButton(
      icon: Icon(Icons.edit, color: Colors.amber, size: hi / 35),
      onPressed: () => showEditPlaylistNameDialog(context, playlist),
    );
  }

  Widget _buildDeleteButton(
      BuildContext context, double hi, PlaylistProvider playlistProvider) {
    return IconButton(
      icon: const Icon(Icons.delete, color: Colors.red),
      onPressed: () async {
        final shouldDelete =
            await _showDeleteConfirmationDialog(context, playlist.name);
        if (shouldDelete) {
          playlistProvider.deletePlaylist(playlist);
          _showDeleteSnackbar(context, playlist.name);
        }
      },
    );
  }

  Future<bool> _showDeleteConfirmationDialog(
      BuildContext context, String playlistName) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Playlist'),
            content: Text('Are you sure you want to delete "$playlistName"?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child:
                    const Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ) ??
        false;
  }

  void _showDeleteSnackbar(BuildContext context, String playlistName) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Deleted $playlistName'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(10),
      ),
    );
  }
}
