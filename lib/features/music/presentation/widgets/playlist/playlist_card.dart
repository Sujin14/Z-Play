import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import '../../../../../core/navigation/router.dart';
import '../../viewmodels/playlist_viewmodel.dart';
import '../../../domain/entities/playlist_entity.dart';
import '../../../../../core/navigation/navigation_service.dart';
import '../../../../../constants/themes.dart';
import 'dialogs/edit_playlist_name_dialog.dart';

class PlaylistCard extends StatelessWidget {
  final PlaylistEntity playlist;

  const PlaylistCard({super.key, required this.playlist});

  @override
  Widget build(BuildContext context) {
    final playlistVM = Provider.of<PlaylistViewModel>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: () => NavigationService.pushNamed(AppRoutes.playlistDetail, arguments: playlist),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(22),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              height: size.height / 3.5,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [theme.colorScheme.primary.withOpacity(0.16), theme.colorScheme.tertiary.withOpacity(0.10)]),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: Colors.white.withOpacity(0.04)),
              ),
              child: Stack(
                children: [
                  Positioned.fill(child: Container()),

                  // Lottie Animation
                  Positioned(top: 8, right: 8, child: SizedBox(width: size.width * 0.30, child: Lottie.asset('assets/json/playlist.json', repeat: true, animate: true))),

                  // Info
                  Positioned(bottom: 16, left: 16, right: 16, child: _playlistInfo(context, playlistVM)),
                  // Actions
                  Positioned(bottom: 10, right: 10, child: Row(children: [
                    _actionButton(icon: Icons.edit, color: theme.colorScheme.editIcon, tooltip: "Edit Playlist", onTap: () => showEditPlaylistNameDialog(context, playlist)),
                    const SizedBox(width: 8),
                    _actionButton(icon: Icons.delete, color: theme.colorScheme.error, tooltip: "Delete Playlist", onTap: () async {
                      final shouldDelete = await _confirmDelete(context);
                      if (shouldDelete) playlistVM.deletePlaylist(playlist);
                    }),
                  ])),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _playlistInfo(BuildContext context, PlaylistViewModel playlistVM) {
    final theme = Theme.of(context);
    return Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
      Text(playlist.name, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: theme.textTheme.bodyLarge!.color, shadows: [Shadow(color: theme.colorScheme.primary, blurRadius: 10)])),
      const SizedBox(height: 6),
      Text("${playlist.songs.length} Tracks", style: TextStyle(color: theme.colorScheme.surface, fontSize: 13)),
    ]);
  }

  Widget _actionButton({required IconData icon, required Color color, required String tooltip, required VoidCallback onTap}) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.25), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.6))),
          child: Icon(icon, color: color, size: 14),
        ),
      ),
    );
  }

  Future<bool> _confirmDelete(BuildContext context) async {
    final theme = Theme.of(context);
    return await showDialog<bool>(context: context, builder: (context) => AlertDialog(title: const Text('Delete Playlist'), content: Text('Delete "${playlist.name}" permanently?'), actions: [TextButton(child: const Text('Cancel'), onPressed: () => Navigator.pop(context, false)), TextButton(child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)), onPressed: () => Navigator.pop(context, true))])) ?? false;
  }
}
