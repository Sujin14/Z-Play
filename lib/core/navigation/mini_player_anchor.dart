import 'package:flutter/widgets.dart';

// Where the mini player sits on screen, so Now Playing can grow out of it and
// minimize back into it without the route importing the shell feature.
class MiniPlayerAnchor {
  static final key = GlobalKey(debugLabel: 'mini player');

  // Shared by the mini player cover and the large Now Playing cover.
  static const coverHeroTag = 'now-playing-cover';

  // The floating bars' geometry; the shell lays itself out with these too, so
  // the computed fallback matches the real position.
  static const double margin = 16;
  static const double navHeight = 68;
  static const double height = 64;
  // The mini player's bottom edge sits 96px above the safe area's bottom.
  static const double bottomOffset = 96;
  static const double gap = bottomOffset - navHeight - margin;

  // The live rect when the mini player is laid out, otherwise where it will
  // sit. Always inside the screen, so a rotation or tiny screen can't produce
  // a rect the route can't draw.
  static Rect rectIn(Size screen, EdgeInsets padding) {
    final screenRect = Offset.zero & screen;
    return _clamp(_liveRect(), screenRect) ??
        _clamp(_computedRect(screen, padding), screenRect) ??
        Rect.fromCenter(center: screenRect.bottomCenter, width: 0, height: 0);
  }

  // Global coordinates match the root navigator's, which fills the screen.
  static Rect? _liveRect() {
    final box = key.currentContext?.findRenderObject();
    if (box is! RenderBox || !box.attached || !box.hasSize) return null;
    return MatrixUtils.transformRect(
        box.getTransformTo(null), Offset.zero & box.size);
  }

  static Rect _computedRect(Size screen, EdgeInsets padding) {
    final bottom = screen.height - padding.bottom - bottomOffset;
    return Rect.fromLTRB(
        margin, bottom - height, screen.width - margin, bottom);
  }

  static Rect? _clamp(Rect? rect, Rect screen) {
    if (rect == null) return null;
    final clamped = rect.intersect(screen);
    return clamped.width > 0 && clamped.height > 0 ? clamped : null;
  }
}
