import 'package:audio_service/audio_service.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'core/app/app.dart';
import 'core/services/app_info_service.dart';
import 'core/services/background_save_observer.dart';
import 'core/services/just_audio_engine.dart';
import 'core/services/media_session_handler.dart';
import 'core/services/media_permission_service.dart';
import 'core/services/platform_capabilities.dart';
import 'core/data/library_store.dart';
import 'core/data/song_scanner.dart';
import 'core/models/music_file_model.dart';
import 'core/models/playlist_model.dart';
import 'core/data/library_repository.dart';
import 'core/data/playlist_repository.dart';
import 'core/state/library_view_model.dart';
import 'core/state/player_view_model.dart';
import 'core/state/playlist_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Fonts are bundled in assets/fonts; the app never goes online.
  GoogleFonts.config.allowRuntimeFetching = false;
  LicenseRegistry.addLicense(() async* {
    for (final family in ['Sora', 'PlusJakartaSans']) {
      final text = await rootBundle.loadString('assets/fonts/OFL-$family.txt');
      yield LicenseEntryWithLineBreaks(['google_fonts'], text);
    }
  });
  final appInfo = await AppInfoService.load();
  final capabilities = PlatformCapabilities.current();
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(MusicFileAdapter().typeId)) {
    Hive.registerAdapter(MusicFileAdapter());
  }
  if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
    Hive.registerAdapter(PlaylistAdapter());
  }

  final store = LibraryStore(
    favoritesBox: await Hive.openBox<String>('favorites'),
    playlistBox: await Hive.openBox<Playlist>('playlistsBox'),
    legacyRecentBox: await Hive.openBox('recentlyPlayedBox'),
    playCountBox: await Hive.openBox<int>('playCountsBox'),
    preferencesBox: await Hive.openBox('preferences'),
  );
  final libraryRepository = LibraryRepository(
    store: store,
    scanner: SongScanner(),
    permissions: DeviceMediaPermissionService(),
  );
  final playlistRepository = PlaylistRepository(store);
  final library = LibraryViewModel(libraryRepository);
  final playlists = PlaylistViewModel(
    repository: playlistRepository,
    library: library,
  );
  library.onCatalogChanged = playlists.load;
  // The media session (notification, lock screen, headset buttons) starts
  // before the player and is attached to it afterwards, so neither has to
  // build the other.
  final session = await AudioService.init(
    builder: MediaSessionHandler.new,
    config: MediaSessionHandler.config,
  );
  final player = PlayerViewModel(
    repository: libraryRepository,
    onPlayed: library.syncActivity,
    engine: JustAudioEngine(),
  );
  session.attach(player);
  WidgetsBinding.instance.addObserver(BackgroundSaveObserver(player.saveNow));

  runApp(
    MultiProvider(
      providers: [
        Provider.value(value: appInfo),
        Provider.value(value: capabilities),
        ChangeNotifierProvider.value(value: library),
        ChangeNotifierProvider.value(value: playlists),
        ChangeNotifierProvider.value(value: player),
      ],
      child: const ZPlayApp(),
    ),
  );
}
