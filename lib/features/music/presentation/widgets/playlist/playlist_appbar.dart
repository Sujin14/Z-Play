import 'package:flutter/material.dart';
import '../../../../../constants/themes.dart';

class PlaylistAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double hi;
  const PlaylistAppBar({super.key, required this.hi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      title: Text(
        'Playlists',
        style: style(fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color),
      ),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
