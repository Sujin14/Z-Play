import 'package:flutter/material.dart';

import '../../../../../constants/themes.dart';

class EmptyFavoritesView extends StatelessWidget {
  const EmptyFavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    return Center(
      child: Text(
        'No favorite songs added yet!',
        style: style(fontSize: hi / 50, fontWeight: FontWeight.normal),
      ),
    );
  }
}
