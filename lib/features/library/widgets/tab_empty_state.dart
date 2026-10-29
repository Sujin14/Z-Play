import 'package:flutter/material.dart';

import '../../../core/widgets/empty_state.dart';

// Keeps an empty state centered above the floating mini player and nav.
class TabEmptyState extends StatelessWidget {
  const TabEmptyState(this.child, {super.key});

  TabEmptyState.nothingYet(IconData icon, {super.key})
      : child = EmptyState(icon: icon, title: 'Nothing to show here yet.');

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.paddingOf(context).bottom),
      child: child,
    );
  }
}
