import '../../../core/models/library_settings_model.dart';
import '../../../core/state/library_view_model.dart';

class SettingsViewModel {
  SettingsViewModel(this._library) : _settings = _library.settings;

  final LibraryViewModel _library;
  final LibrarySettings _settings;

  static const version = '1.0.0+3';

  bool get darkTheme => _settings.darkTheme;
  bool get includeShortClips => _settings.includeShortClips;
  bool get includeSystemSounds => _settings.includeSystemSounds;
  List<String> get hiddenFolders => _settings.hiddenFolders;
  bool get hasHiddenFolders => hiddenFolders.isNotEmpty;

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

  void showFolder(String folder) => _library.unhideFolder(folder);
}
