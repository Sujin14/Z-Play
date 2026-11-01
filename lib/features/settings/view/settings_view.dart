import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/app/app_name.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/services/app_info_service.dart';
import '../../../core/services/platform_capabilities.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/theme/app_spacing.dart';
import '../view_model/settings_view_model.dart';
import '../widgets/chevron_icon.dart';
import '../widgets/setting_row.dart';
import '../widgets/settings_card.dart';
import '../widgets/settings_footer.dart';
import '../widgets/settings_section_label.dart';
import '../widgets/toggle_switch.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = SettingsViewModel(
      context.watch<LibraryViewModel>(),
      context.read<AppInfoService>(),
      context.read<PlatformCapabilities>(),
    );
    final text = Theme.of(context).textTheme;
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: EdgeInsets.fromLTRB(
            AppSpacing.screen,
            16,
            AppSpacing.screen,
            24 + MediaQuery.paddingOf(context).bottom,
          ),
          children: [
            Text(appName.toUpperCase(), style: text.labelSmall),
            const SizedBox(height: 4),
            Text('Settings', style: text.headlineLarge),
            const SettingsSectionLabel('Appearance'),
            SettingsCard(children: [
              SettingRow(
                icon: Icons.dark_mode_outlined,
                title: 'Dark theme',
                trailing: ToggleSwitch(
                    value: settings.darkTheme,
                    onChanged: settings.setDarkTheme),
                onTap: settings.toggleDarkTheme,
              ),
            ]),
            const SettingsSectionLabel('Library'),
            SettingsCard(children: [
              SettingRow(
                icon: Icons.timer_outlined,
                title: 'Show clips under 60 seconds',
                subtitle:
                    'Voice notes and notification sounds stay hidden unless this is on.',
                trailing: ToggleSwitch(
                    value: settings.includeShortClips,
                    onChanged: settings.setIncludeShortClips),
                onTap: settings.toggleShortClips,
              ),
              SettingRow(
                icon: Icons.notifications_none_rounded,
                title: 'Show ringtones, alarms, and notifications',
                trailing: ToggleSwitch(
                    value: settings.includeSystemSounds,
                    onChanged: settings.setIncludeSystemSounds),
                onTap: settings.toggleSystemSounds,
              ),
              SettingRow(
                icon: Icons.refresh_rounded,
                title: 'Rescan storage',
                subtitle: settings.rescanSubtitle,
                trailing: const ChevronIcon(),
                onTap: settings.rescan,
              ),
              if (settings.showsHiddenFolders)
                SettingRow(
                  icon: Icons.visibility_off_outlined,
                  title: 'Hidden folders',
                  subtitle: settings.hiddenFoldersSummary,
                  trailing: const ChevronIcon(),
                  onTap: () =>
                      NavigationService.pushNamed(AppRoutes.hiddenFolders),
                ),
            ]),
            const SettingsSectionLabel('Listening history'),
            SettingsCard(children: [
              SettingRow(
                icon: Icons.history_rounded,
                title: 'Recently played',
                trailing: const ChevronIcon(),
                onTap: () => NavigationService.pushNamed(AppRoutes.recent),
              ),
              SettingRow(
                icon: Icons.trending_up_rounded,
                title: 'Most played',
                trailing: const ChevronIcon(),
                onTap: () => NavigationService.pushNamed(AppRoutes.mostPlayed),
              ),
            ]),
            const SettingsSectionLabel('About'),
            SettingsCard(children: [
              SettingRow(
                icon: Icons.help_outline_rounded,
                title: 'Help & FAQ',
                trailing: const ChevronIcon(),
                onTap: () => NavigationService.pushNamed(AppRoutes.help),
              ),
              SettingRow(
                icon: Icons.info_outline_rounded,
                title: 'About',
                trailing: const ChevronIcon(),
                onTap: () => NavigationService.pushNamed(AppRoutes.about),
              ),
              SettingRow(
                icon: Icons.shield_outlined,
                title: 'Privacy policy',
                trailing: const ChevronIcon(),
                onTap: () => NavigationService.pushNamed(AppRoutes.privacy),
              ),
              SettingRow(
                icon: Icons.description_outlined,
                title: 'Terms and conditions',
                trailing: const ChevronIcon(),
                onTap: () => NavigationService.pushNamed(AppRoutes.terms),
              ),
            ]),
            const SizedBox(height: 32),
            SettingsFooter(version: settings.version),
          ],
        ),
      ),
    );
  }
}
