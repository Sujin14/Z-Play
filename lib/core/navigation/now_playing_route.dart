import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show PredictiveBackEvent;

import '../theme/app_radii.dart';
import '../theme/app_tokens.dart';
import 'mini_player_anchor.dart';

typedef AnchorRect = Rect Function(Size screen, EdgeInsets padding);

// Now Playing grows out of the mini player and minimizes back into it. The
// page is laid out once at full size; only the clip, two opacities and the
// controller change per frame, so nothing inside the page rebuilds.
class NowPlayingRoute<T> extends PageRoute<T> {
  NowPlayingRoute({
    required this.builder,
    super.settings,
    this.anchor = MiniPlayerAnchor.rectIn,
  });

  final WidgetBuilder builder;
  // Tests pass a fixed rect; the app uses the mini player's.
  final AnchorRect anchor;

  static const morphKey = ValueKey('now-playing-morph');
  static const fadeKey = ValueKey('now-playing-fade');
  // Emphasized easing is ~80% done after a quarter of the time, so at this
  // length it would jump and then crawl; this one spreads the motion evenly.
  static const curve = Curves.easeInOutCubic;

  static const _openDuration = Duration(milliseconds: 750);
  static const _closeDuration = Duration(milliseconds: 750);
  static const _fadeDuration = Duration(milliseconds: 150);
  static const _minSettleDuration = Duration(milliseconds: 250);
  static const _settleCurve = Curves.easeOutCubic;
  static const double _dismissFraction = 0.25;
  static const double _flingVelocity = 700;
  // Fractions of the route's linear progress, i.e. of the elapsed time. The
  // gradient fill shows first so the rect is visible from the start; the
  // content fades in mid-growth on open and is the first thing to go on close
  // (progress 1 to 0.6 is the first 40% of closing).
  static const _fillFade = Interval(0, 0.15);
  static const _contentFadeIn = Interval(0.35, 0.85);
  static const _contentFadeOut = Interval(0.6, 1);

  bool _gestureActive = false;
  bool _dragging = false;
  bool _backGesture = false;
  double _dragDistance = 0;
  double _dragExtent = 1;
  double _dragHeight = 1;

  bool get _reduceMotion =>
      MediaQuery.maybeDisableAnimationsOf(navigator!.context) ?? false;

  @override
  Duration get transitionDuration =>
      _reduceMotion ? _fadeDuration : _openDuration;

  @override
  Duration get reverseTransitionDuration =>
      _reduceMotion ? _fadeDuration : _closeDuration;

  @override
  bool get opaque => true;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
          Animation<double> secondaryAnimation) =>
      builder(context);

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    if (MediaQuery.disableAnimationsOf(context)) {
      return FadeTransition(key: fadeKey, opacity: animation, child: child);
    }
    // A finger or back gesture maps 1:1 to progress; only timed runs curve.
    bool gesture() => navigator?.userGestureInProgress ?? false;
    final progress = _DerivedAnimation(
        animation, (value) => gesture() ? value : curve.transform(value));
    // Opening and closing stagger the content differently; a drag or back
    // gesture is always heading toward closing.
    final contentOpacity = _DerivedAnimation(animation, (value) {
      final closing = gesture() || animation.status == AnimationStatus.reverse;
      return (closing ? _contentFadeOut : _contentFadeIn).transform(value);
    });
    final padding = MediaQuery.paddingOf(context);
    return _PredictiveBackListener(
      route: this,
      child: ClipRRect(
        key: morphKey,
        clipper: NowPlayingClipper(
          progress: progress,
          anchor: (size) => anchor(size, padding),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            FadeTransition(
              opacity: _DerivedAnimation(animation, _fillFade.transform),
              child: DecoratedBox(
                decoration:
                    BoxDecoration(gradient: AppTokens.of(context).background),
              ),
            ),
            FadeTransition(
              opacity: contentOpacity,
              child: RepaintBoundary(child: child),
            ),
          ],
        ),
      ),
    );
  }

  void startMinimizeDrag() {
    final controller = this.controller;
    if (_gestureActive || !isCurrent || controller == null) return;
    final media = MediaQuery.of(subtreeContext!);
    _gestureActive = _dragging = true;
    _dragDistance = 0;
    _dragHeight = media.size.height;
    // Moving the clip's top edge by the finger's distance needs the gap
    // between the top of the screen and the mini player.
    _dragExtent = anchor(media.size, media.padding).top.clamp(1, _dragHeight);
    // Switching to linear progress mid-open would jump; start from what is
    // on screen instead.
    controller.value = curve.transform(controller.value);
    navigator!.didStartUserGesture();
  }

  void updateMinimizeDrag(double delta) {
    if (!_dragging) return;
    _dragDistance += delta;
    controller!.value -= delta / _dragExtent;
  }

  void endMinimizeDrag(double velocity) {
    if (!_dragging) return;
    _dragging = false;
    final flungDown = velocity > _flingVelocity;
    final flungUp = velocity < -_flingVelocity;
    final farEnough = _dragDistance > _dismissFraction * _dragHeight;
    _settle(dismiss: flungDown || (farEnough && !flungUp));
  }

  // The predictive back gesture drives the controller through
  // TransitionRoute's defaults; only its ending is replaced, because the
  // default restarts the pop from fully open.
  @override
  void handleStartBackGesture({double progress = 0.0}) {
    if (_gestureActive) return;
    _gestureActive = _backGesture = true;
    super.handleStartBackGesture(progress: progress);
  }

  @override
  void handleUpdateBackGestureProgress({required double progress}) {
    if (!_backGesture) return;
    super.handleUpdateBackGestureProgress(progress: progress);
  }

  @override
  void handleCancelBackGesture() {
    if (!_backGesture) return;
    _backGesture = false;
    _settle(dismiss: false);
  }

  @override
  void handleCommitBackGesture() {
    if (!_backGesture) return;
    _backGesture = false;
    _settle(dismiss: true);
  }

  void _settle({required bool dismiss}) {
    final controller = this.controller!;
    final navigator = this.navigator!;
    if (dismiss && isCurrent) {
      navigator.pop();
      // pop() reverses from here with the page curve; finish from the
      // finger's position instead.
      if (controller.isAnimating) {
        controller.animateBack(0,
            duration: _settleDuration(_closeDuration, controller.value),
            curve: _settleCurve);
      }
    } else if (!dismiss) {
      controller.animateTo(1,
          duration: _settleDuration(_openDuration, 1 - controller.value),
          curve: _settleCurve);
    }
    void finish() {
      _gestureActive = false;
      navigator.didStopUserGesture();
    }

    if (!controller.isAnimating) {
      finish();
      return;
    }
    // Progress stays linear until the settle ends, so it doesn't jump when
    // the curve comes back.
    late final AnimationStatusListener onStatus;
    onStatus = (status) {
      if (status.isAnimating) return;
      controller.removeStatusListener(onStatus);
      finish();
    };
    controller.addStatusListener(onStatus);
  }

  // Only the remaining part of the run, so a nearly finished drag or a fling
  // doesn't take the full length; the floor keeps short ones visible.
  static Duration _settleDuration(Duration full, double remaining) {
    final scaled = full * remaining;
    return scaled < _minSettleDuration ? _minSettleDuration : scaled;
  }
}

// The rounded rect between the mini player (progress 0) and the full screen
// (progress 1). Re-clips on every tick without rebuilding anything.
class NowPlayingClipper extends CustomClipper<RRect> {
  NowPlayingClipper({required this.progress, required this.anchor})
      : super(reclip: progress);

  final Animation<double> progress;
  final Rect Function(Size size) anchor;

  @override
  RRect getClip(Size size) {
    final t = progress.value.clamp(0.0, 1.0);
    final rect = Rect.lerp(anchor(size), Offset.zero & size, t)!;
    return RRect.fromRectAndRadius(
        rect, Radius.circular(lerpDouble(AppRadii.miniPlayer, 0, t)!));
  }

  @override
  bool shouldReclip(NowPlayingClipper oldClipper) =>
      oldClipper.progress != progress || oldClipper.anchor != anchor;
}

// A view of the parent's value; it registers no listeners of its own, so the
// ones built per buildTransitions call need no disposing.
class _DerivedAnimation extends Animation<double>
    with AnimationWithParentMixin<double> {
  _DerivedAnimation(this.parent, this.transform);

  @override
  final Animation<double> parent;
  final double Function(double value) transform;

  @override
  double get value => transform(parent.value);
}

// Forwards Android's predictive back events to the route. They only arrive
// when the app opts in to them in the Android manifest; otherwise back is a
// plain pop, which plays the same close animation.
class _PredictiveBackListener extends StatefulWidget {
  const _PredictiveBackListener({required this.route, required this.child});

  final NowPlayingRoute<dynamic> route;
  final Widget child;

  @override
  State<_PredictiveBackListener> createState() =>
      _PredictiveBackListenerState();
}

class _PredictiveBackListenerState extends State<_PredictiveBackListener>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    final route = widget.route;
    if (backEvent.isButtonEvent ||
        !route.isCurrent ||
        !route.popGestureEnabled) {
      return false;
    }
    route.handleStartBackGesture(progress: 1 - backEvent.progress);
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    widget.route
        .handleUpdateBackGestureProgress(progress: 1 - backEvent.progress);
  }

  @override
  void handleCancelBackGesture() => widget.route.handleCancelBackGesture();

  @override
  void handleCommitBackGesture() => widget.route.handleCommitBackGesture();

  @override
  Widget build(BuildContext context) => widget.child;
}
