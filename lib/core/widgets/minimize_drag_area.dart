import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';

import '../navigation/now_playing_route.dart';

// Dragging down here minimizes Now Playing into the mini player. Only wrap
// parts with no vertical gestures of their own (the top bar, the cover), so
// the seek bar and sliders never start a dismissal.
class MinimizeDragArea extends StatelessWidget {
  const MinimizeDragArea({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final route = ModalRoute.of(context);
    if (route is! NowPlayingRoute) return child;
    return RawGestureDetector(
      behavior: HitTestBehavior.translucent,
      gestures: {
        _DownwardDragRecognizer:
            GestureRecognizerFactoryWithHandlers<_DownwardDragRecognizer>(
          () => _DownwardDragRecognizer(
            canStart: () => _atScrollStart(context),
            debugOwner: this,
          ),
          (recognizer) => recognizer
            ..onStart = ((_) => route.startMinimizeDrag())
            ..onUpdate = ((details) =>
                route.updateMinimizeDrag(details.primaryDelta ?? 0))
            ..onEnd = ((details) =>
                route.endMinimizeDrag(details.primaryVelocity ?? 0))
            ..onCancel = (() => route.endMinimizeDrag(0)),
        ),
      },
      child: child,
    );
  }

  // When the page is scrolled down, a downward drag scrolls it back first.
  static bool _atScrollStart(BuildContext context) {
    final position = Scrollable.maybeOf(context)?.position;
    if (position == null || !position.hasPixels) return true;
    return position.pixels <= position.minScrollExtent;
  }
}

// Claims the pointer only for a downward drag from the scroll start, so an
// upward drag still scrolls the page.
class _DownwardDragRecognizer extends VerticalDragGestureRecognizer {
  _DownwardDragRecognizer({required this.canStart, super.debugOwner});

  final bool Function() canStart;

  @override
  bool hasSufficientGlobalDistanceToAccept(
    PointerDeviceKind pointerDeviceKind,
    double? deviceTouchSlop,
  ) {
    return globalDistanceMoved > 0 &&
        canStart() &&
        super.hasSufficientGlobalDistanceToAccept(
            pointerDeviceKind, deviceTouchSlop);
  }
}
