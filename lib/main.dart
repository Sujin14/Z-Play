import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:musicplayer/view/splash/splash_screen.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:musicplayer/view_model/providers/playlist_provider.dart';
import 'package:musicplayer/view_model/providers/ui_provider.dart';
import 'package:musicplayer/constants/themes.dart';
import 'package:provider/provider.dart';

import 'model/model.dart';

/// Entry point of the application.
/// Initializes Hive, registers adapters, and sets up providers.
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _initializeHive();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => MusicProvider()),
        ChangeNotifierProvider(create: (context) => TabProvider()),
        ChangeNotifierProvider(create: (context) => PlaylistProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

/// Initializes Hive database and opens required boxes.
Future<void> _initializeHive() async {
  await Hive.initFlutter();

  // Register Hive Adapters if not already registered
  if (!Hive.isAdapterRegistered(PlaylistAdapter().typeId)) {
    Hive.registerAdapter(PlaylistAdapter());
  }
  if (!Hive.isAdapterRegistered(MusicFileAdapter().typeId)) {
    Hive.registerAdapter(MusicFileAdapter());
  }

  // Open Hive boxes for storing data
  await Future.wait([
    Hive.openBox('musicBox'),
    Hive.openBox<String>('favorites'),
    Hive.openBox<Playlist>('playlistsBox'),
    Hive.openBox('recentlyPlayedBox'),
  ]);
}

/// Main application widget with dynamic theme switching.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: darkTheme,
          title: 'Music Player',
          home: const SplashScreen(),
        );
      },
    );
  }
}
