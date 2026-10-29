import 'dart:async';

import 'package:flutter/material.dart';

// "Search title" → "Search artist" → "Search album", one word at a time.
// Freezes on the current word while paused (the field is focused), and shows
// the full hint without motion when the system asks to reduce animations.
class RotatingSearchHint extends StatefulWidget {
  const RotatingSearchHint({super.key, required this.paused});

  final bool paused;

  static const fullHint = 'Search title, artist, album';

  @override
  State<RotatingSearchHint> createState() => _RotatingSearchHintState();
}

class _RotatingSearchHintState extends State<RotatingSearchHint> {
  static const _words = ['title', 'artist', 'album'];
  static const _interval = Duration(milliseconds: 2500);
  static const _transition = Duration(milliseconds: 300);
  // How far (as a fraction of its height) a word slides in from below.
  static const double _slideFrom = 0.4;

  Timer? _timer;
  int _index = 0;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncTimer();
  }

  @override
  void didUpdateWidget(RotatingSearchHint oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncTimer();
  }

  bool get _reduceMotion => MediaQuery.disableAnimationsOf(context);

  void _syncTimer() {
    final shouldRun = !widget.paused && !_reduceMotion;
    if (shouldRun && _timer == null) {
      _timer = Timer.periodic(_interval, (_) {
        if (mounted) setState(() => _index = (_index + 1) % _words.length);
      });
    } else if (!shouldRun) {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Screen readers get one stable hint instead of a changing one.
    return Semantics(
      label: RotatingSearchHint.fullHint,
      child: ExcludeSemantics(
        child: _reduceMotion
            ? const Text(RotatingSearchHint.fullHint,
                maxLines: 1, overflow: TextOverflow.ellipsis)
            : Row(
                children: [
                  const Text('Search '),
                  Flexible(
                    child: ClipRect(
                      child: AnimatedSwitcher(
                        duration: _transition,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: AlignmentDirectional.centerStart,
                          children: [...previous, if (current != null) current],
                        ),
                        transitionBuilder: (child, animation) => FadeTransition(
                          opacity: animation,
                          child: SlideTransition(
                            position: Tween(
                                    begin: const Offset(0, _slideFrom),
                                    end: Offset.zero)
                                .animate(animation),
                            child: child,
                          ),
                        ),
                        child: Text(_words[_index],
                            key: ValueKey(_index), maxLines: 1),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
