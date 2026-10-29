import 'package:flutter/material.dart';

import '../../../core/theme/app_radii.dart';
import '../../../core/theme/app_tokens.dart';
import 'setting_row.dart';
import 'settings_card.dart';
import 'settings_section_label.dart';

class HiddenFoldersSection extends StatelessWidget {
  const HiddenFoldersSection(
      {super.key, required this.folders, required this.onShow});

  final List<String> folders;
  final ValueChanged<String> onShow;

  static const _folderLines = 2;

  @override
  Widget build(BuildContext context) {
    final tokens = AppTokens.of(context);
    final text = Theme.of(context).textTheme;
    // Stretch keeps the full-width layout these had as separate list items.
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SettingsSectionLabel(
          'Hidden folders',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
            decoration: BoxDecoration(
                color: tokens.chip,
                borderRadius: BorderRadius.circular(AppRadii.pill)),
            child: Text(
              '${folders.length}',
              style: text.labelMedium?.copyWith(
                  color: tokens.accentText, fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SettingsCard(children: [
          for (final folder in folders)
            SettingRow(
              icon: Icons.folder_outlined,
              // The full path, since that's what identifies the folder.
              title: folder,
              titleStyle: text.bodyMedium?.copyWith(color: tokens.text),
              titleLines: _folderLines,
              trailing: IconButton(
                tooltip: 'Show folder',
                onPressed: () => onShow(folder),
                icon: Icon(Icons.visibility_outlined, color: tokens.accentText),
              ),
            ),
        ]),
      ],
    );
  }
}
