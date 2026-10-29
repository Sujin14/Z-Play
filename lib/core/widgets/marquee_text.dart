import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';

// One line of text that scrolls right to left only when it doesn't fit.
// Short text, and anyone with reduce motion on, gets a plain line that ends
// in "…" instead.
class MarqueeText extends StatelessWidget {
  const MarqueeText(this.text, {super.key, required this.style});

  final String text;
  final TextStyle style;

  static const double _gap = 40;
  static const double _velocity = 30;
  static const _pause = Duration(seconds: 2);

  @override
  Widget build(BuildContext context) {
    final plain = Text(
      text,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: style,
    );
    if (MediaQuery.disableAnimationsOf(context)) return plain;
    return LayoutBuilder(
      builder: (context, constraints) {
        final painter = TextPainter(
          text: TextSpan(text: text, style: style),
          maxLines: 1,
          textDirection: Directionality.of(context),
          textScaler: MediaQuery.textScalerOf(context),
        )..layout();
        final height = painter.height;
        final overflows = painter.width > constraints.maxWidth;
        painter.dispose();
        if (!overflows) return plain;
        return SizedBox(
          height: height,
          child: Marquee(
            // A new key per text restarts the scroll from the start when the
            // song changes, instead of continuing mid-way through.
            key: ValueKey(text),
            text: text,
            style: style,
            blankSpace: _gap,
            velocity: _velocity,
            pauseAfterRound: _pause,
            startAfter: _pause,
          ),
        );
      },
    );
  }
}
