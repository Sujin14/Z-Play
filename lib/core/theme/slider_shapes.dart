import 'package:flutter/material.dart';

class GradientSliderTrackShape extends SliderTrackShape
    with BaseSliderTrackShape {
  const GradientSliderTrackShape(this.gradient);

  final Gradient gradient;

  @override
  void paint(
    PaintingContext context,
    Offset offset, {
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required Animation<double> enableAnimation,
    required Offset thumbCenter,
    Offset? secondaryOffset,
    bool isEnabled = false,
    bool isDiscrete = false,
    required TextDirection textDirection,
  }) {
    final rect = getPreferredRect(
      parentBox: parentBox,
      offset: offset,
      sliderTheme: sliderTheme,
      isEnabled: isEnabled,
      isDiscrete: isDiscrete,
    );
    final radius = Radius.circular(rect.height / 2);
    final canvas = context.canvas;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, radius),
      Paint()..color = sliderTheme.inactiveTrackColor ?? Colors.white24,
    );
    final ltr = textDirection == TextDirection.ltr;
    final active = ltr
        ? Rect.fromLTRB(rect.left, rect.top, thumbCenter.dx, rect.bottom)
        : Rect.fromLTRB(thumbCenter.dx, rect.top, rect.right, rect.bottom);
    if (active.width <= 0) return;
    // The shader spans the whole track so the gradient doesn't squash as the
    // thumb moves.
    canvas.drawRRect(
      RRect.fromRectAndRadius(active, radius),
      Paint()..shader = gradient.createShader(rect),
    );
  }
}

class RingSliderThumbShape extends SliderComponentShape {
  const RingSliderThumbShape({this.ring = const Color(0x6639FF5A)});

  // The light theme passes a darker green: the default ring nearly vanishes
  // around a white thumb on a light background.
  final Color ring;

  static const double _ringRadius = 12;
  static const double _thumbRadius = 8;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) =>
      const Size.square(_ringRadius * 2);

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final canvas = context.canvas;
    canvas.drawCircle(center, _ringRadius, Paint()..color = ring);
    canvas.drawCircle(center, _thumbRadius, Paint()..color = Colors.white);
  }
}
