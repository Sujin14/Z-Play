import 'package:flutter/material.dart';
import '../../../../../constants/themes.dart';

class PlaylistEmptyView extends StatelessWidget {
  final double hi;
  const PlaylistEmptyView({super.key, required this.hi});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No songs in this playlist!',
        style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
      ),
    );
  }
}
