import 'package:flutter/material.dart';

class AlbumArtWidget extends StatelessWidget {
  const AlbumArtWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: hi / 6,
          width: hi / 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: theme.colorScheme.primary,
          ),
        ),
        Container(
          height: hi / 9,
          width: hi / 9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: theme.colorScheme.secondary,
          ),
        ),
        Container(
          height: hi / 15,
          width: hi / 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: theme.colorScheme.surface,
          ),
        ),
      ],
    );
  }
}
