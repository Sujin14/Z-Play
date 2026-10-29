import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/models/song_model.dart';
import '../../../core/services/song_actions.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/marquee_text.dart';
import '../../../core/widgets/round_icon_button.dart';

class PlayerTitleRow extends StatelessWidget {
  const PlayerTitleRow({super.key, required this.song});

  final Song song;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    // Watched here so a favorite change only rebuilds this row.
    final favorite = context.watch<LibraryViewModel>().isFavorite(song);
    final style = text.headlineMedium!;
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MarqueeText(song.title, style: style),
              const SizedBox(height: 4),
              Text(
                song.subtitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: text.bodyLarge?.copyWith(color: tokens.text2),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        RoundIconButton(
          icon:
              favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          tooltip: favorite ? 'Remove from favorites' : 'Add to favorites',
          color: favorite ? tokens.heart : null,
          onPressed: () => toggleFavorite(context, song),
        ),
      ],
    );
  }
}
