import 'package:flutter/material.dart';

/// Common Text Style Function
/// - Returns a text style with default values for font size, weight, and color.
/// - Used throughout the app to maintain consistency in text styling.
TextStyle style({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
}) =>
    TextStyle(
      color: color ?? Colors.white,
      fontWeight: fontWeight ?? FontWeight.bold,
      overflow: TextOverflow.fade,
      fontSize: fontSize ?? 20,
    );

/// Dark Theme Definition
/// - Defines a custom dark theme for the app, including colors, text styles, and icon themes.
/// - This theme is applied to the entire app via the 'MaterialApp' widget.
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1A1A2E),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF2D4059),
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    bodyLarge: style(color: Color(0xFFE8F1F5)), // Off-white
    bodyMedium: style(color: Color(0xFFA7B8BF)), // Soft gray
    headlineLarge: style(
        fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE8F1F5)),
    labelLarge: style(fontSize: 18, color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFE8F1F5)),
  primaryColor: const Color(0xFF3FC1C9), // Muted teal
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3FC1C9), // Muted teal
    secondary: Color(0xFFFCB173), // Peach
    tertiary: Color(0xFF6C5CE7), // Soft purple
    surface: Color(0xFF16213E), // Dark blue
    surfaceContainerHighest: Color(0xFF2D4059), // Dark slate
    error: Color(0xFFE74C3C), // Soft red
  ),
);

/// Album Art Widget
/// - Displays a circular album art container with layered colors.
class AlbumArtWidget extends StatelessWidget {
  const AlbumArtWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          height: hi / 6,
          width: hi / 6,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        Container(
          height: hi / 9,
          width: hi / 9,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
        Container(
          height: hi / 15,
          width: hi / 15,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: Theme.of(context).colorScheme.surface,
          ),
        )
      ],
    );
  }
}
