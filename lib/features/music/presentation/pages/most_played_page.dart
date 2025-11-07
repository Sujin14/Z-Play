import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../constants/themes.dart';
import '../viewmodels/music_viewmodel.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../widgets/most_played/most_played_list.dart';
import '../widgets/most_played/empty_most_played_view.dart';

class MostPlayedPage extends StatelessWidget {
  const MostPlayedPage({super.key});

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(
          'Most Played',
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
          child: Consumer2<MusicViewModel, PlaylistViewModel>(
            builder: (context, musicVM, playlistVM, _) {
              if (musicVM.isLoading) {
                return Center(
                  child: CircularProgressIndicator(color: theme.colorScheme.primary),
                );
              }

              if (musicVM.mostPlayedSongs.isEmpty) {
                return EmptyMostPlayedView(hi: hi);
              }

              return MostPlayedList(
                musicVM: musicVM,
                playlistVM: playlistVM,
              );
            },
          ),
        ),
      ),
    );
  }
}
