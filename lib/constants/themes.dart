import 'package:flutter/material.dart';

TextStyle style({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
}) =>
    TextStyle(
      color: color ?? const Color.fromARGB(255, 229, 145, 145),
      fontWeight: fontWeight ?? FontWeight.bold,
      overflow: TextOverflow.fade,
      fontSize: fontSize ?? 20,
    );

extension CustomColors on ColorScheme {
  Color get cardBackground => const Color.fromARGB(255, 101, 97, 119);
  Color get musicIcon => const Color(0xFF2196F3);
  Color get historyIcon => Colors.blue;
  Color get trendingIcon => Colors.green;
  Color get favoriteIconFilled => Colors.red;
  Color get favoriteIconEmpty => Colors.white;
  Color get editIcon => Colors.amber;
  Color get shuffleIcon => Colors.deepOrangeAccent;
  Color get gradientStart => const Color(0xFF28286E);
  Color get gradientEnd => const Color(0xFF727375);
  Color get gradientControlStart => const Color(0xFF23025D);
  Color get gradientControlEnd => const Color(0xFF1891ED);
  Color get shadowColor => Colors.black26;
}

ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF1A1A2E),
  appBarTheme: const AppBarTheme(
    color: Color(0xFF2D4059),
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    bodyLarge: style(color: Color(0xFFE8F1F5)),
    bodyMedium: style(color: Color(0xFFA7B8BF)),
    headlineLarge: style(
        fontSize: 32, fontWeight: FontWeight.bold, color: Color(0xFFE8F1F5)),
    labelLarge: style(fontSize: 18, color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFE8F1F5)),
  primaryColor: const Color(0xFF3FC1C9),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF3FC1C9),
    secondary: Color(0xFFFCB173),
    tertiary: Color(0xFF6C5CE7),
    surface: Color(0xFF16213E),
    surfaceContainerHighest: Color(0xFF2D4059),
    error: Color(0xFFE74C3C),
  ),
);