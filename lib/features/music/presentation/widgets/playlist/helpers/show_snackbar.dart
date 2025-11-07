import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String message, Color color) {
  final theme = Theme.of(context);
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message, style: TextStyle(color: theme.textTheme.bodyLarge!.color)),
      behavior: SnackBarBehavior.floating,
      backgroundColor: color,
      margin: const EdgeInsets.all(10),
      duration: const Duration(seconds: 2),
    ),
  );
}
