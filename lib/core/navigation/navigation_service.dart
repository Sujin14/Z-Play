import 'package:flutter/material.dart';

import 'app_router.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return navigatorKey.currentState!
        .pushNamed(routeName, arguments: arguments);
  }

  static Future<dynamic> pushReplacementNamed(String routeName,
      {Object? arguments}) {
    return navigatorKey.currentState!
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  // Pops back to the main shell if it is underneath; otherwise (e.g. a bad
  // route reached straight from the splash) replaces the current page with it.
  static void backToMain() {
    final navigator = navigatorKey.currentState!;
    var foundMain = false;
    navigator.popUntil((route) {
      if (route.settings.name == AppRoutes.main) {
        foundMain = true;
        return true;
      }
      return route.isFirst;
    });
    if (!foundMain) navigator.pushReplacementNamed(AppRoutes.main);
  }
}
