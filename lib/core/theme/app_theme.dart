import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_radii.dart';
import 'app_tokens.dart';
import 'fade_up_page_transition.dart';
import 'slider_shapes.dart';

abstract final class AppTheme {
  static ThemeData dark() => _build(Brightness.dark, AppTokens.dark);

  static ThemeData light() => _build(Brightness.light, AppTokens.light);

  // The handoff's type table mapped onto textTheme slots: headlineLarge =
  // screen title, headlineMedium = player title, titleLarge = sheet and
  // empty-state title, titleMedium = row title, bodyMedium = subtitle,
  // labelSmall = eyebrow.
  static TextTheme _textTheme(AppTokens t) {
    final base = GoogleFonts.plusJakartaSansTextTheme().apply(
      bodyColor: t.text,
      displayColor: t.text,
    );
    return base.copyWith(
      headlineLarge: GoogleFonts.sora(
        fontSize: 30,
        fontWeight: FontWeight.w800,
        letterSpacing: -0.6,
        height: 1.1,
        color: t.text,
      ),
      headlineMedium: GoogleFonts.sora(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: t.text,
      ),
      headlineSmall: GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: t.text,
      ),
      titleLarge: GoogleFonts.sora(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: t.text,
      ),
      titleMedium: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: t.text,
      ),
      titleSmall: GoogleFonts.plusJakartaSans(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: t.text,
      ),
      bodyLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: t.text,
      ),
      bodyMedium: GoogleFonts.plusJakartaSans(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: t.text2,
      ),
      bodySmall: GoogleFonts.plusJakartaSans(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: t.text2,
      ),
      labelLarge: GoogleFonts.plusJakartaSans(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: t.text,
      ),
      labelMedium: GoogleFonts.plusJakartaSans(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: t.text,
      ),
      labelSmall: GoogleFonts.plusJakartaSans(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.76,
        color: t.accentText,
      ),
    );
  }

  static ThemeData _build(Brightness brightness, AppTokens t) {
    final dark = brightness == Brightness.dark;
    final primary = dark ? AppColors.neon : AppColors.lPrimary;
    final scheme = ColorScheme(
      brightness: brightness,
      primary: primary,
      onPrimary: AppColors.onAccent,
      secondary: AppColors.aqua,
      onSecondary: AppColors.onAccent,
      tertiary: AppColors.lime,
      onTertiary: AppColors.onAccent,
      error: t.heart,
      onError: dark ? AppColors.onAccent : Colors.white,
      surface: t.sheet,
      onSurface: t.text,
      onSurfaceVariant: t.text2,
      surfaceContainerHighest: t.sheet,
      outline: t.line,
      outlineVariant: t.line,
      surfaceTint: Colors.transparent,
    );
    final text = _textTheme(t);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      canvasColor: t.sheet,
      textTheme: text,
      extensions: [t],
      splashFactory: InkSparkle.splashFactory,
      iconTheme: IconThemeData(color: t.text, size: 22),
      dividerTheme: DividerThemeData(color: t.line, thickness: 1, space: 1),
      sliderTheme: SliderThemeData(
        trackHeight: 6,
        trackShape: const GradientSliderTrackShape(AppColors.action),
        thumbShape: dark
            ? const RingSliderThumbShape()
            : RingSliderThumbShape(
                ring: AppColors.lAccentText.withValues(alpha: 0.55)),
        activeTrackColor: primary,
        inactiveTrackColor: t.line,
        overlayColor: AppColors.neon.withValues(alpha: 0.12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        // #16C24A is ~2.3:1 on the light gradient; the text green reads clearly.
        color: t.accentText,
        linearTrackColor: t.line,
        circularTrackColor: t.line,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: t.card,
        hintStyle: text.bodyLarge?.copyWith(color: t.text2),
        labelStyle: text.bodyMedium,
        prefixIconColor: t.text2,
        suffixIconColor: t.text2,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: t.line),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: t.line),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: primary, width: 1.2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide(color: t.heart),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: primary,
        selectionColor: primary.withValues(alpha: 0.3),
        selectionHandleColor: primary,
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: t.text,
          minimumSize: const Size(44, 44),
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: t.sheet,
        modalBackgroundColor: t.sheet,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalBarrierColor: Colors.black.withValues(alpha: dark ? 0.55 : 0.3),
        dragHandleColor: t.line,
        shape: const RoundedRectangleBorder(
          borderRadius:
              BorderRadius.vertical(top: Radius.circular(AppRadii.sheet)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: t.sheet,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.card),
          side: BorderSide(color: t.line),
        ),
        titleTextStyle: text.titleLarge,
        contentTextStyle: text.bodyLarge?.copyWith(color: t.text2),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: t.sheet,
        surfaceTintColor: Colors.transparent,
        textStyle: text.titleSmall,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: t.line),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: t.sheet,
        contentTextStyle: text.titleSmall,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.miniPlayer),
          side: BorderSide(color: t.line),
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeUpPageTransitionsBuilder(),
          TargetPlatform.iOS: FadeUpPageTransitionsBuilder(),
          TargetPlatform.windows: FadeUpPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeUpPageTransitionsBuilder(),
          TargetPlatform.linux: FadeUpPageTransitionsBuilder(),
        },
      ),
    );
  }
}
