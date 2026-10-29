import 'package:flutter/material.dart';

import '../../../core/widgets/wordmark.dart';

class SettingsFooter extends StatelessWidget {
  const SettingsFooter({super.key, required this.version});

  final String version;

  static const double _wordmarkSize = 24;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Center(child: Wordmark(fontSize: _wordmarkSize)),
        const SizedBox(height: 6),
        Center(
            child: Text('Version $version',
                style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
