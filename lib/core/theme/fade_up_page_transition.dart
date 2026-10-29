import 'package:flutter/material.dart';

class FadeUpPageTransitionsBuilder extends PageTransitionsBuilder {
  const FadeUpPageTransitionsBuilder();

  static const _duration = Duration(milliseconds: 250);
  static const double _slide = 8;

  @override
  Duration get transitionDuration => _duration;

  @override
  Duration get reverseTransitionDuration => _duration;

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final curved =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: curved,
      child: AnimatedBuilder(
        animation: curved,
        child: child,
        builder: (context, child) => Transform.translate(
          offset: Offset(0, _slide * (1 - curved.value)),
          child: child,
        ),
      ),
    );
  }
}
