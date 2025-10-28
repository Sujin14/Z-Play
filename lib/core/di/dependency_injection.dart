import 'package:get_it/get_it.dart';
import '../../features/music/domain/usecases/get_playlists.dart';
import '../storage/hive_storage.dart';
import '../../features/music/data/repositories/music_repository_impl.dart';
import '../../features/music/data/repositories/playlist_repository_impl.dart';
import '../../features/music/domain/repositories/music_repository.dart';
import '../../features/music/domain/repositories/playlist_repository.dart';
import '../../features/music/domain/usecases/fetch_music_files.dart';
import '../../features/music/domain/usecases/toggle_favorite.dart';
import '../../features/music/domain/usecases/create_playlist.dart';
import '../../features/music/domain/usecases/manage_playlist.dart';
import '../../features/music/domain/usecases/add_recently_played.dart';
import '../../features/music/domain/usecases/get_most_played.dart';
import '../../features/music/presentation/viewmodels/music_viewmodel.dart';
import '../../features/music/presentation/viewmodels/playlist_viewmodel.dart';
import '../../features/music/presentation/viewmodels/theme_viewmodel.dart';

final GetIt getIt = GetIt.instance;

void setupDependencies() {
  // Storage
  getIt.registerSingleton<HiveStorage>(HiveStorage());

  // Repositories
  getIt.registerSingleton<MusicRepository>(
      MusicRepositoryImpl(hiveStorage: getIt<HiveStorage>()));
  getIt.registerSingleton<PlaylistRepository>(
      PlaylistRepositoryImpl(hiveStorage: getIt<HiveStorage>()));

  // Use Cases
  getIt.registerSingleton<FetchMusicFiles>(
      FetchMusicFiles(getIt<MusicRepository>()));
  getIt.registerSingleton<ToggleFavorite>(
      ToggleFavorite(getIt<MusicRepository>()));
  getIt.registerSingleton<CreatePlaylist>(
      CreatePlaylist(getIt<PlaylistRepository>()));
  getIt.registerSingleton<ManagePlaylist>(
      ManagePlaylist(getIt<PlaylistRepository>()));
  getIt.registerLazySingleton(() => GetPlaylists(getIt()));

  getIt.registerSingleton<AddRecentlyPlayed>(
      AddRecentlyPlayed(getIt<MusicRepository>()));
  getIt.registerSingleton<GetMostPlayed>(
      GetMostPlayed(getIt<MusicRepository>()));

  // ViewModels
  getIt.registerFactory<MusicViewModel>(() => MusicViewModel(
        fetchMusicFiles: getIt<FetchMusicFiles>(),
        toggleFavorite: getIt<ToggleFavorite>(),
        addRecentlyPlayed: getIt<AddRecentlyPlayed>(),
        getMostPlayed: getIt<GetMostPlayed>(),
      ));
  getIt.registerFactory<PlaylistViewModel>(() => PlaylistViewModel(
      createPlaylist: getIt<CreatePlaylist>(),
      managePlaylist: getIt<ManagePlaylist>(),
      getPlaylists: getIt<GetPlaylists>()));
  getIt.registerFactory<ThemeViewModel>(() => ThemeViewModel());
}

