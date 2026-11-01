import '../../../core/state/library_view_model.dart';

class HiddenFoldersViewModel {
  HiddenFoldersViewModel(this._library)
      : folders = _library.settings.hiddenFolders;

  final LibraryViewModel _library;

  // Full paths, since that is what identifies a folder.
  final List<String> folders;

  bool get isEmpty => folders.isEmpty;

  // Saving the settings notifies listeners, so the page drops the row at once.
  void show(String folder) => _library.unhideFolder(folder);
}
