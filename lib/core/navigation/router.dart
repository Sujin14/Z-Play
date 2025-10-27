import 'package:flutter/material.dart';
import '../../features/music/presentation/pages/splash_page.dart';
import '../../features/music/presentation/pages/home_page.dart';
import '../../features/music/presentation/pages/favorites_page.dart';
import '../../features/music/presentation/pages/playlist_page.dart';
import '../../features/music/presentation/pages/playlist_detail_page.dart';
import '../../features/music/presentation/pages/recently_played_page.dart';
import '../../features/music/presentation/pages/most_played_page.dart';
import '../../features/music/presentation/pages/music_player_page.dart';
import '../../features/music/presentation/pages/about_page.dart';
import '../../features/music/presentation/pages/privacy_policy_page.dart';
import '../../features/music/presentation/pages/terms_conditions_page.dart';
import '../../features/music/presentation/pages/settings_page.dart';
import '../../features/music/presentation/pages/main_page.dart';
import '../../features/music/domain/entities/music_file_entity.dart';
import '../../features/music/domain/entities/playlist_entity.dart';

class AppRoutes {
  static const String splash = '/';
  static const String main = '/main';
  static const String home = '/home';
  static const String favorites = '/favorites';
  static const String playlists = '/playlists';
  static const String playlistDetail = '/playlist_detail';
  static const String recentlyPlayed = '/recently_played';
  static const String mostPlayed = '/most_played';
  static const String musicPlayer = '/music_player';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy_policy';
  static const String termsConditions = '/terms_conditions';
  static const String settings = '/settings';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen());
      case main:
        return MaterialPageRoute(builder: (_) => const MainPage());
      case home:
        return MaterialPageRoute(builder: (_) => const HomePage());
      case favorites:
        return MaterialPageRoute(builder: (_) => const FavoritesPage());
      case playlists:
        return MaterialPageRoute(builder: (_) => const PlaylistScreen());
      case playlistDetail:
        final playlist = settings.arguments as PlaylistEntity;
        return MaterialPageRoute(
            builder: (_) => PlaylistDetailScreen(playlist: playlist));
      case recentlyPlayed:
        return MaterialPageRoute(builder: (_) => const RecentlyPlayedPage());
      case mostPlayed:
        return MaterialPageRoute(builder: (_) => const MostPlayedPage());
      case musicPlayer:
        final args = settings.arguments as Map<String, dynamic>;
        final musicFile = args['musicFile'] as MusicFileEntity;
        final playlist = args['playlist'] as List<MusicFileEntity>;
        return MaterialPageRoute(
            builder: (_) => MusicPlayer(musicFile: musicFile, playlist: playlist));
      case about:
        return MaterialPageRoute(builder: (_) => const AboutPage());
      case privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyPage());
      case termsConditions:
        return MaterialPageRoute(builder: (_) => const TermsConditionsPage());
      case AppRoutes.settings:
        return MaterialPageRoute(builder: (_) => const SettingsPage());
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}