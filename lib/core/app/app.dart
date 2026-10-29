import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../navigation/navigation_service.dart';
import '../navigation/app_router.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../state/library_view_model.dart';

class ZPlayApp extends StatelessWidget {
  const ZPlayApp({super.key});

  @override
  Widget build(BuildContext context) {
    final darkTheme = context.watch<LibraryViewModel>().settings.darkTheme;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Z-PLAY',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: darkTheme ? ThemeMode.dark : ThemeMode.light,
      navigatorKey: NavigationService.navigatorKey,
      initialRoute: AppRoutes.splash,
      onGenerateRoute: AppRoutes.generateRoute,
      builder: (context, child) => AnnotatedRegion<SystemUiOverlayStyle>(
        value: _systemBars(Theme.of(context).brightness == Brightness.dark),
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }

  // Light status/navigation bar icons on dark, dark icons on light. The bar
  // colors match the gradient ends for Android versions that still paint
  // them; edge-to-edge versions draw the app behind them instead.
  static SystemUiOverlayStyle _systemBars(bool dark) {
    return SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: dark ? Brightness.light : Brightness.dark,
      statusBarBrightness: dark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor: dark ? AppColors.dEnd : AppColors.lEnd,
      systemNavigationBarDividerColor: Colors.transparent,
      systemNavigationBarIconBrightness:
          dark ? Brightness.light : Brightness.dark,
      systemNavigationBarContrastEnforced: false,
    );
  }
}
