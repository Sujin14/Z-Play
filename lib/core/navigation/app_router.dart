import 'package:flutter/material.dart';

import '../../features/favorites/view/favorites_view.dart';
import '../../features/help/view/help_view.dart';
import '../../features/hidden_folders/view/hidden_folders_view.dart';
import '../../features/library/view/library_view.dart';
import '../../features/not_found/view/not_found_view.dart';
import '../../features/shell/view/shell_view.dart';
import '../../features/splash/view/splash_view.dart';
import '../../features/history/view/history_view.dart';
import '../../features/history/view_model/history_view_model.dart';
import '../models/collection_args_model.dart';
import 'now_playing_route.dart';
import '../../features/collection/view/collection_view.dart';
import '../../features/info/model/info_page_model.dart';
import '../../features/info/view/info_view.dart';
import '../../features/player/view/player_view.dart';
import '../../features/playlists/view/playlists_view.dart';
import '../../features/playlists/view/playlist_detail_view.dart';
import '../../features/queue/view/queue_view.dart';
import '../../features/settings/view/settings_view.dart';

class AppRoutes {
  static const splash = '/';
  static const main = '/main';
  static const player = '/player';
  static const queue = '/queue';
  static const collection = '/collection';
  static const playlist = '/playlist';
  static const recent = '/recent';
  static const mostPlayed = '/most-played';
  static const about = '/about';
  static const privacy = '/privacy';
  static const terms = '/terms';
  static const hiddenFolders = '/hidden-folders';
  static const help = '/help';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashView());
      case main:
        return MaterialPageRoute(
          builder: (_) => const ShellView(
            tabs: [
              LibraryView(),
              FavoritesView(),
              PlaylistsView(),
              SettingsView()
            ],
          ),
        );
      case player:
        return NowPlayingRoute(
            settings: settings, builder: (_) => const PlayerView());
      case queue:
        return MaterialPageRoute(builder: (_) => const QueueView());
      case collection:
        final args = settings.arguments! as CollectionArgs;
        return MaterialPageRoute(builder: (_) => CollectionView(args: args));
      case playlist:
        final name = settings.arguments! as String;
        return MaterialPageRoute(
            builder: (_) => PlaylistDetailView(name: name));
      case recent:
        return MaterialPageRoute(
          builder: (_) => const HistoryView(kind: HistoryKind.recent),
        );
      case mostPlayed:
        return MaterialPageRoute(
          builder: (_) => const HistoryView(kind: HistoryKind.mostPlayed),
        );
      case about:
        return MaterialPageRoute(
            builder: (_) => const InfoView(kind: InfoKind.about));
      case privacy:
        return MaterialPageRoute(
            builder: (_) => const InfoView(kind: InfoKind.privacy));
      case terms:
        return MaterialPageRoute(
            builder: (_) => const InfoView(kind: InfoKind.terms));
      case hiddenFolders:
        return MaterialPageRoute(builder: (_) => const HiddenFoldersView());
      case help:
        return MaterialPageRoute(builder: (_) => const HelpView());
      default:
        return MaterialPageRoute(
          builder: (_) => NotFoundView(routeName: settings.name),
        );
    }
  }
}
