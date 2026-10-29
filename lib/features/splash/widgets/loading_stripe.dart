import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_tokens.dart';

// Indeterminate on purpose: the library scan reports no progress value.
class LoadingStripe extends StatefulWidget {
  const LoadingStripe({super.key});

  @override
  State<LoadingStripe> createState() => _LoadingStripeState();
}

class _LoadingStripeState extends State<LoadingStripe>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: _cycle,
  )..repeat();

  static const _cycle = Duration(milliseconds: 1400);
  static const double _width = 240;
  static const double _height = 4;
  static const double _segmentFraction = 0.4;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final segment = _width * _segmentFraction;
    return Semantics(
      label: 'Loading',
      child: ClipRRect(
        borderRadius: BorderRadius.circular(_height),
        child: Container(
          width: _width,
          height: _height,
          color: tokens.line,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = Curves.easeInOut.transform(_controller.value);
              // Starts fully off the left edge and ends fully off the right.
              return Stack(
                children: [
                  Positioned(
                    left: -segment + (_width + segment) * t,
                    top: 0,
                    bottom: 0,
                    width: segment,
                    child: const DecoratedBox(
                        decoration: BoxDecoration(gradient: AppColors.action)),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
