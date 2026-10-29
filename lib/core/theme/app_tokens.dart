import 'package:flutter/material.dart';

import 'app_colors.dart';

// Per-theme colors that ColorScheme has no slot for. Widgets read these via
// AppTokens.of(context) so one widget works in both themes.
@immutable
class AppTokens extends ThemeExtension<AppTokens> {
  const AppTokens({
    required this.background,
    required this.accent,
    required this.accentText,
    required this.text,
    required this.text2,
    required this.card,
    required this.line,
    required this.chip,
    required this.glass,
    required this.sheet,
    required this.heart,
  });

  final LinearGradient background;
  // Fills and icons. Use accentText for text: on light, accent is too pale.
  final Color accent;
  final Color accentText;
  final Color text;
  final Color text2;
  final Color card;
  final Color line;
  final Color chip;
  final Color glass;
  final Color sheet;
  final Color heart;

  static const dark = AppTokens(
    background: AppColors.darkBg,
    accent: AppColors.neon,
    accentText: AppColors.neon,
    text: AppColors.dText,
    text2: AppColors.dText2,
    card: AppColors.dCard,
    line: AppColors.dLine,
    chip: AppColors.dChip,
    glass: AppColors.dGlass,
    sheet: AppColors.dSheet,
    heart: AppColors.dHeart,
  );

  static const light = AppTokens(
    background: AppColors.lightBg,
    accent: AppColors.lPrimary,
    accentText: AppColors.lAccentText,
    text: AppColors.lText,
    text2: AppColors.lText2,
    card: AppColors.lCard,
    line: AppColors.lLine,
    chip: AppColors.lChip,
    glass: AppColors.lGlass,
    sheet: AppColors.lSheet,
    heart: AppColors.lHeart,
  );

  static AppTokens of(BuildContext context) {
    return Theme.of(context).extension<AppTokens>() ?? dark;
  }

  @override
  AppTokens copyWith({
    LinearGradient? background,
    Color? accent,
    Color? accentText,
    Color? text,
    Color? text2,
    Color? card,
    Color? line,
    Color? chip,
    Color? glass,
    Color? sheet,
    Color? heart,
  }) {
    return AppTokens(
      background: background ?? this.background,
      accent: accent ?? this.accent,
      accentText: accentText ?? this.accentText,
      text: text ?? this.text,
      text2: text2 ?? this.text2,
      card: card ?? this.card,
      line: line ?? this.line,
      chip: chip ?? this.chip,
      glass: glass ?? this.glass,
      sheet: sheet ?? this.sheet,
      heart: heart ?? this.heart,
    );
  }

  // Lets MaterialApp animate the theme switch instead of snapping.
  @override
  AppTokens lerp(AppTokens? other, double t) {
    if (other == null) return this;
    return AppTokens(
      background: LinearGradient.lerp(background, other.background, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentText: Color.lerp(accentText, other.accentText, t)!,
      text: Color.lerp(text, other.text, t)!,
      text2: Color.lerp(text2, other.text2, t)!,
      card: Color.lerp(card, other.card, t)!,
      line: Color.lerp(line, other.line, t)!,
      chip: Color.lerp(chip, other.chip, t)!,
      glass: Color.lerp(glass, other.glass, t)!,
      sheet: Color.lerp(sheet, other.sheet, t)!,
      heart: Color.lerp(heart, other.heart, t)!,
    );
  }
}
