import '../../../core/models/song_model.dart';
import '../../../core/state/library_view_model.dart';
import '../../../core/utils/format_utils.dart';

class FavoritesViewModel {
  FavoritesViewModel(LibraryViewModel library) : songs = library.favorites;

  final List<Song> songs;

  bool get isEmpty => songs.isEmpty;

  String get countLabel =>
      '${songs.length} ${songs.length == 1 ? 'song' : 'songs'}';

  // Empty when no favorite has a known length; the card then shows the count only.
  String get durationLabel => formatTotalDuration(songs);
}
