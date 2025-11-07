import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/themes.dart';
import '../viewmodels/music_viewmodel.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../widgets/favorites/empty_favorites_view.dart';
import '../widgets/favorites/favorite_list.dart';
import '../widgets/favorites/loading_indicator.dart';


class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final musicViewModel = Provider.of<MusicViewModel>(context);
    final playlistViewModel = Provider.of<PlaylistViewModel>(context, listen: false);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Favorites',
          style: style(fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [theme.colorScheme.gradientStart, theme.colorScheme.gradientEnd],
          ),
        ),
        child: SafeArea(
          child: Builder(
            builder: (_) {
              if (musicViewModel.isLoading) {
                return const LoadingIndicator();
              } else if (musicViewModel.favorites.isEmpty) {
                return const EmptyFavoritesView();
              } else {
                return FavoriteList(
                  favorites: musicViewModel.favorites,
                  musicViewModel: musicViewModel,
                  playlistViewModel: playlistViewModel,
                );
              }
            },
          ),
        ),
      ),
    );
  }
}
