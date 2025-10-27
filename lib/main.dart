import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicplayer/core/navigation/navigation_service.dart';
import 'package:provider/provider.dart';
import 'core/di/dependency_injection.dart';
import 'core/navigation/router.dart';
import 'features/music/data/models/music_file.dart';
import 'features/music/data/models/playlist.dart';
import 'features/music/presentation/viewmodels/music_viewmodel.dart';
import 'features/music/presentation/viewmodels/playlist_viewmodel.dart';
import 'features/music/presentation/viewmodels/theme_viewmodel.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeHive();
  setupDependencies();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => getIt<MusicViewModel>()),
        ChangeNotifierProvider(create: (context) => getIt<PlaylistViewModel>()),
        ChangeNotifierProvider(create: (context) => getIt<ThemeViewModel>()),
      ],
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeHive() async {
  await Hive.initFlutter();
  if (!Hive.isAdapterRegistered(MusicFileAdapter().typeId)) {
    Hive.registerAdapter(MusicFileAdapter());
  }
  if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
    Hive.registerAdapter(PlaylistAdapter());
  }
  await Future.wait([
    Hive.openBox('musicBox'),
    Hive.openBox<String>('favorites'),
    Hive.openBox<Playlist>('playlistsBox'),
    Hive.openBox('recentlyPlayedBox'),
    Hive.openBox<int>('playCountsBox'),
  ]);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: ThemeData.dark(),
          title: 'Z-PLAY',
          navigatorKey: NavigationService.navigatorKey,
          initialRoute: AppRoutes.splash,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
