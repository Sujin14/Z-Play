import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';
import '../model/segment_option_model.dart';

class SegmentedPill<T> extends StatelessWidget {
  const SegmentedPill({
    super.key,
    required this.segments,
    required this.selected,
    required this.onChanged,
  });

  final List<SegmentOption<T>> segments;
  final T selected;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: BoxDecoration(
        color: tokens.card,
        borderRadius: BorderRadius.circular(AppRadii.pill),
        border: Border.all(color: tokens.line),
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          children: [
            for (final segment in segments)
              Expanded(
                child: _Segment(
                  segment: segment,
                  selected: segment.value == selected,
                  onTap: () => onChanged(segment.value),
                  tokens: tokens,
                  style: text.titleSmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Segment<T> extends StatelessWidget {
  const _Segment({
    required this.segment,
    required this.selected,
    required this.onTap,
    required this.tokens,
    required this.style,
  });

  final SegmentOption<T> segment;
  final bool selected;
  final VoidCallback onTap;
  final AppTokens tokens;
  final TextStyle? style;

  static const _animation = Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.onAccent : tokens.text2;
    return Semantics(
      selected: selected,
      button: true,
      child: AnimatedContainer(
        duration: _animation,
        decoration: BoxDecoration(
          gradient: selected ? AppColors.action : null,
          borderRadius: BorderRadius.circular(AppRadii.pill),
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            customBorder: const StadiumBorder(),
            onTap: onTap,
            child: SizedBox(
              height: AppSizes.touchTarget,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (segment.icon != null) ...[
                    Icon(segment.icon, size: AppSizes.iconSmall, color: color),
                    const SizedBox(width: 8),
                  ],
                  Flexible(
                    child: Text(
                      segment.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: style?.copyWith(color: color),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
