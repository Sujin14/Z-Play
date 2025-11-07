import 'package:flutter/material.dart';

class EmptyMusicView extends StatelessWidget {
  final String searchQuery;
  const EmptyMusicView({super.key, required this.searchQuery});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          searchQuery.isNotEmpty ? "Sorry, no matching songs!" : "No songs found. Retry?",
          style: TextStyle(fontSize: 18, color: theme.textTheme.bodyMedium!.color),
        ),
      ),
    );
  }
}
