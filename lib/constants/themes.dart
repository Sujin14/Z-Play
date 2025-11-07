import 'package:flutter/material.dart';

TextStyle style({
  double? fontSize,
  FontWeight? fontWeight,
  Color? color,
}) =>
    TextStyle(
      color: color ?? const Color(0xFFE8F1F5),
      fontWeight: fontWeight ?? FontWeight.w600,
      overflow: TextOverflow.fade,
      fontSize: fontSize ?? 16,
      letterSpacing: 0.2,
    );

extension CustomColors on ColorScheme {
  Color get cardBackground => const Color(0x1AFFFFFF);
  Color get musicIcon => const Color(0xFF6DE7FF);
  Color get historyIcon => const Color(0xFF8E8EF9);
  Color get trendingIcon => const Color(0xFF7EFFC7);
  Color get favoriteIconFilled => const Color(0xFFFF6B81);
  Color get favoriteIconEmpty => const Color(0xFFBDBDBD);
  Color get editIcon => const Color(0xFFFFC857);
  Color get shuffleIcon => const Color(0xFFFF8A65);
  Color get gradientStart => const Color(0xFF0F0F1A);
  Color get gradientEnd => const Color(0xFF1B122B);
  Color get gradientControlStart => const Color(0xFF0B1020);
  Color get gradientControlEnd => const Color(0xFF2B1B5A);
  Color get shadowColor => Colors.black26;
  Color get neonGlow => const Color(0xFF7C4DFF);
  Color get glassFill => Colors.white.withOpacity(0.03);
  Color get glassBorder => Colors.white.withOpacity(0.04);
  Color get glassShadow => Colors.black.withOpacity(0.45);
  Color get inputShadow => Colors.black.withOpacity(0.4);
  Color get actionButtonBackground => Colors.black.withOpacity(0.25);
  Color get surfaceContainerHighest => const Color(0xFF2D4059);
}

final ThemeData darkTheme = ThemeData(
  useMaterial3: false,
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF080812),
  appBarTheme: const AppBarTheme(
    color: Colors.transparent,
    elevation: 0,
    centerTitle: true,
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: TextTheme(
    bodyLarge: style(color: const Color(0xFFE8F1F5)),
    bodyMedium: style(color: const Color(0xFF9DAAB0)),
    headlineLarge: style(
        fontSize: 32, fontWeight: FontWeight.bold, color: const Color(0xFFE8F1F5)),
    labelLarge: style(fontSize: 18, color: Colors.white),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFE8F1F5)),
  primaryColor: const Color(0xFF7C4DFF),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF7C4DFF),
    secondary: Color(0xFF3FC1C9),
    tertiary: Color(0xFF6C5CE7),
    surface: Color(0xFF101025),
    surfaceVariant: Color(0xFF131326),
    shadow: Colors.black26,
    error: Color(0xFFE74C3C),
  ),
);