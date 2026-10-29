import '../../../core/models/collection_args_model.dart';
import '../../../core/models/collection_kind_model.dart';
import '../../../core/models/song_model.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/utils/format_utils.dart';
import '../../../core/utils/text_utils.dart';

class CollectionViewModel {
  CollectionViewModel(LibraryViewModel library, this.args)
      : songs = library.songsFor(args.kind, args.id);

  final CollectionArgs args;
  final List<Song> songs;

  CollectionKind get kind => args.kind;
  String get title => args.title;
  String get eyebrow => kind.name;
  bool get hasSongs => songs.isNotEmpty;
  bool get isAlbum => kind == CollectionKind.album;
  bool get isArtist => kind == CollectionKind.artist;
  String get emptyTitle => 'No songs in this ${kind.name}.';

  // Album pages lead with the artist; folder and artist pages only count.
  String get subtitle {
    if (!isAlbum) return tracksLabel(songs);
    return songs.isEmpty
        ? tracksLabel(songs)
        : '${albumArtist(songs)} · ${tracksLabel(songs)}';
  }

  // Album rows already sit under the album name, so they only show the artist.
  String Function(Song song)? get rowSubtitle =>
      isAlbum ? (song) => song.artist : null;
}
