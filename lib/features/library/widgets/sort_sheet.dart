import 'package:flutter/material.dart';

import '../../../core/models/song_sort_model.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_sizes.dart';
import '../../../core/theme/app_tokens.dart';
import '../../../core/widgets/app_sheet.dart';

Future<void> showSortSheet(BuildContext context, LibraryViewModel library) {
  return showAppSheet<void>(
    context,
    builder: (sheetContext) => SortSheet(library: library),
  );
}

class SortSheet extends StatelessWidget {
  const SortSheet({super.key, required this.library});

  final LibraryViewModel library;

  static const _options = [
    (SongSort.title, 'Title', Icons.title_rounded),
    (SongSort.artist, 'Artist', Icons.person_outline_rounded),
    (SongSort.album, 'Album', Icons.album_outlined),
    (SongSort.dateAdded, 'Date added', Icons.calendar_today_outlined),
    (SongSort.duration, 'Duration', Icons.schedule_rounded),
  ];

  static const double _rowRadius = 14;

  @override
  Widget build(BuildContext context) {
    return AppSheet(
      title: 'Sort by',
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final (value, label, icon) in _options)
              _row(context, value, label, icon),
          ],
        ),
      ),
    );
  }

  Widget _row(
      BuildContext context, SongSort value, String label, IconData icon) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    final selected = library.sort == value;
    return Semantics(
      selected: selected,
      child: InkWell(
        borderRadius: BorderRadius.circular(_rowRadius),
        onTap: () {
          library.setSort(value);
          Navigator.pop(context);
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            children: [
              Container(
                width: AppSizes.iconTile,
                height: AppSizes.iconTile,
                decoration: BoxDecoration(
                  color: selected ? tokens.chip : tokens.card,
                  borderRadius: BorderRadius.circular(AppRadii.small),
                ),
                child: Icon(icon,
                    size: AppSizes.icon,
                    color: selected ? tokens.accentText : tokens.text2),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  label,
                  style: text.titleMedium?.copyWith(
                    color: selected ? tokens.accentText : tokens.text,
                  ),
                ),
              ),
              if (selected) Icon(Icons.check_rounded, color: tokens.accentText),
            ],
          ),
        ),
      ),
    );
  }
}
