import '../../../core/models/library_settings_model.dart';
import '../../../core/services/app_info_service.dart';
import '../../../core/services/platform_capabilities.dart';
import '../../../core/state/library_view_model.dart';

class SettingsViewModel {
  SettingsViewModel(this._library, this._appInfo, this._capabilities)
      : _settings = _library.settings;

  final LibraryViewModel _library;
  final AppInfoService _appInfo;
  final PlatformCapabilities _capabilities;
  final LibrarySettings _settings;

  bool get darkTheme => _settings.darkTheme;
  bool get includeShortClips => _settings.includeShortClips;
  bool get includeSystemSounds => _settings.includeSystemSounds;

  String get version => _appInfo.version;

  bool get showsHiddenFolders => _capabilities.supportsFolders;

  // Where there are folders the scan also walks storage; on iOS it only
  // reads the music library.
  String get rescanSubtitle => _capabilities.supportsFolders
      ? 'Read every mounted volume and the system music index again.'
      : 'Refresh your music library';

  String get hiddenFoldersSummary {
    final count = _settings.hiddenFolders.length;
    if (count == 0) return 'None hidden';
    return '$count ${count == 1 ? 'folder' : 'folders'} hidden';
  }

  void setDarkTheme(bool value) =>
      _library.updateSettings(_settings.copyWith(darkTheme: value));

  void setIncludeShortClips(bool value) =>
      _library.updateSettings(_settings.copyWith(includeShortClips: value));

  void setIncludeSystemSounds(bool value) =>
      _library.updateSettings(_settings.copyWith(includeSystemSounds: value));

  // Tapping anywhere on a switch row flips it, same as tapping the switch.
  void toggleDarkTheme() => setDarkTheme(!darkTheme);
  void toggleShortClips() => setIncludeShortClips(!includeShortClips);
  void toggleSystemSounds() => setIncludeSystemSounds(!includeSystemSounds);

  void rescan() => _library.rescan();
}
