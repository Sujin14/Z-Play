import 'package:flutter/material.dart';
import '../../../../../constants/themes.dart';

class PlaylistDetailAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String playlistName;
  final VoidCallback onAddPressed;

  const PlaylistDetailAppBar({
    super.key,
    required this.playlistName,
    required this.onAddPressed,
  });

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        playlistName,
        style: style(fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_circle_outline, size: 30),
          onPressed: onAddPressed,
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
