import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:musicplayer/constants/themes.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';
import '../../../../core/navigation/router.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../../domain/entities/playlist_entity.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../widgets/playlist_dialogs.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistEntity playlist;

  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final playlistVM = Provider.of<PlaylistViewModel>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => NavigationService.pushNamed(
        AppRoutes.playlistDetail,
        arguments: playlist,
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              height: size.height / 3,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: LinearGradient(
                  colors: [
                    theme.colorScheme.primary.withOpacity(0.3),
                    theme.colorScheme.tertiary.withOpacity(0.3),
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.3),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    alignment: Alignment.bottomLeft,
                    child: _playlistInfo(context, playlistVM),
                  ),
                ),
              ),
            ),

            // Lottie Animation
            Positioned(
              top: 5,
              right: 15,
              child: Lottie.asset(
                'assets/json/playlist.json',
                width: size.width * 0.30,
                repeat: true,
                animate: true,
              ),
            ),

            Positioned(
              bottom: 16,
              right: 16,
              child: Row(
                children: [
                  _actionButton(
                    icon: Icons.edit,
                    color: theme.colorScheme.editIcon,
                    tooltip: "Edit Playlist",
                    onTap: () => showEditPlaylistNameDialog(context, playlist),
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    icon: Icons.delete,
                    color: theme.colorScheme.error,
                    tooltip: "Delete Playlist",
                    onTap: () async {
                      final shouldDelete = await _confirmDelete(context);
                      if (shouldDelete) playlistVM.deletePlaylist(playlist);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _playlistInfo(BuildContext context, PlaylistViewModel playlistVM) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: theme.textTheme.bodyLarge!.color,
            shadows: [
              Shadow(color: theme.colorScheme.primary, blurRadius: 10),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "${playlist.songs.length} Tracks",
          style: TextStyle(color: theme.colorScheme.surface, fontSize: 14),
        ),
      ],
    );
  }

  Widget _actionButton({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.25),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: color.withOpacity(0.6)),
          ),
          child: Icon(icon, color: color, size: 10),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final theme = Theme.of(context);
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Delete Playlist'),
            content: Text('Delete "${playlist.name}" permanently?'),
            actions: [
              TextButton(
                child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context, false),
              ),
              TextButton(
                child:
                    Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                onPressed: () => Navigator.pop(context, true),
              ),
            ],
          ),
        ) ??
        false;
  }
}