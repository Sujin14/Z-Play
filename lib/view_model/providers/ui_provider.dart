import 'package:flutter/material.dart';

TabProvider tabProvider = TabProvider();

class TabProvider with ChangeNotifier {
  int _currentIndex = 0; // Default to Home tab
  int get currentIndex => _currentIndex;

  void onTabTapped(int index, BuildContext context) {
    _currentIndex = index;
    notifyListeners(); // Notify listeners to update UI
  }
}

ThemeProvider themeProvider = ThemeProvider();

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  // Toggle between light and dark mode
  void toggleTheme(bool isDark) {
    _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    notifyListeners(); // Notify listeners to rebuild the UI
  }
}
