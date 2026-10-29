import 'package:flutter/widgets.dart';

// An item's position in the list is its tab index.
class NavBarItem {
  const NavBarItem(
      {required this.icon, required this.label, this.selectedIcon});

  final IconData icon;
  // Falls back to icon when the tab has no filled variant.
  final IconData? selectedIcon;
  final String label;
}
