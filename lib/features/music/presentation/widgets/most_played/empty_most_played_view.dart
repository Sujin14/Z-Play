import 'package:flutter/material.dart';
import '../../../../../constants/themes.dart';

class EmptyMostPlayedView extends StatelessWidget {
  final double hi;
  const EmptyMostPlayedView({super.key, required this.hi});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Text(
        'No songs played more than 5 times yet!',
        style: style(
          fontSize: hi / 50,
          fontWeight: FontWeight.normal,
          color: theme.textTheme.bodyMedium!.color,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
