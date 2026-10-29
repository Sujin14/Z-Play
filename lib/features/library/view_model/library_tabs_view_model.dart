import '../../../core/models/collection_args_model.dart';
import '../../../core/models/collection_kind_model.dart';
import '../../../core/models/song_group_model.dart';
import '../../../core/models/song_model.dart';
import '../../../core/models/song_sort_model.dart';
import '../../../core/navigation/app_router.dart';
import '../../../core/navigation/navigation_service.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/utils/text_utils.dart';

class LibraryTabsViewModel {
  const LibraryTabsViewModel(this.library, {required this.selectedTab});

  final LibraryViewModel library;
  final int selectedTab;

  static const tabs = ['Songs', 'Folders', 'Albums', 'Artists'];
  static const _songsTab = 0;

  static const _sortLabels = {
    SongSort.title: 'Title · A–Z',
    SongSort.artist: 'Artist · A–Z',
    SongSort.album: 'Album · A–Z',
    SongSort.dateAdded: 'Date added · Newest',
    SongSort.duration: 'Duration · Longest',
  };

  bool get isLoading => library.loading;

  // Folders, albums and artists are always A–Z by name, so only Songs sorts.
  bool get showsSort => selectedTab == _songsTab;

  String get sortLabel => _sortLabels[library.sort]!;

  // Blank while scanning so a stale count doesn't flash.
  String get countLabel {
    if (library.loading) return '';
    final (count, noun) = switch (selectedTab) {
      0 => (library.songs.length, 'song'),
      1 => (library.folders.length, 'folder'),
      2 => (library.albums.length, 'album'),
      _ => (library.artists.length, 'artist'),
    };
    return '$count ${count == 1 ? noun : '${noun}s'}';
  }

  List<Song> get songs => library.songs;
  List<SongGroup> get folders => library.folders;
  List<SongGroup> get albums => library.albums;
  List<SongGroup> get artists => library.artists;

  // Only a failed scan with nothing to show is an error; a partial scan still
  // lists what it found.
  bool get showsError => library.error != null && library.songs.isEmpty;
  String get error => library.error!;
  bool get isSearching => library.query.isNotEmpty;

  bool isFavorite(Song song) => library.isFavorite(song);

  String folderSubtitle(SongGroup group) =>
      '${group.subtitle} · ${shortStoragePath(group.id)}';

  String albumSubtitle(SongGroup group) =>
      '${albumArtist(group.songs)} · ${group.subtitle}';

  void openGroup(CollectionKind kind, SongGroup group) {
    NavigationService.pushNamed(
      AppRoutes.collection,
      arguments: CollectionArgs(kind: kind, id: group.id, title: group.title),
    );
  }
}
