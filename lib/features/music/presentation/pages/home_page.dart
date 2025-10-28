import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:provider/provider.dart';
import '../../../../core/navigation/router.dart';
import '../../../../core/navigation/navigation_service.dart';
import '../../../../core/permissions/permissions_handler.dart';
import '../../../music/presentation/widgets/playlist_dialogs.dart';
import '../../../../constants/themes.dart';
import '../viewmodels/music_viewmodel.dart';
import '../viewmodels/playlist_viewmodel.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  bool isSearchActive = false;
  final FocusNode searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (await PermissionsHandler.requestStoragePermission()) {
        context.read<MusicViewModel>().requestStoragePermissionAndFetchFiles();
      }
    });
  }

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final theme = Theme.of(context);
    final musicVM = context.watch<MusicViewModel>();
    final playlistVM = context.read<PlaylistViewModel>();

    final filteredMusicFiles = searchQuery.isEmpty
        ? musicVM.musicFiles
        : musicVM.musicFiles
            .where((m) => m.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text("Z-PLAY",
            style: style(fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color)),
        actions: [
          IconButton(
            icon: Icon(isSearchActive ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearchActive = !isSearchActive;
                if (!isSearchActive) {
                  searchQuery = '';
                  searchController.clear();
                  FocusScope.of(context).unfocus();
                } else {
                  searchFocusNode.requestFocus();
                }
              });
            },
          )
        ],
      ),

      body: Column(
        children: [
          if (isSearchActive)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 80,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: searchController,
                  focusNode: searchFocusNode,
                  onChanged: (q) => setState(() => searchQuery = q),
                  onSubmitted: (_) => FocusScope.of(context).unfocus(),
                  decoration: InputDecoration(
                    hintText: "Search music files...",
                    prefixIcon: const Icon(Icons.search),
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    hintStyle: TextStyle(color: theme.textTheme.bodyMedium!.color),
                  ),
                ),
              ),
            ),

          Expanded(
            child: musicVM.isLoading
                ? Center(child: CircularProgressIndicator(color: theme.colorScheme.primary,))
                : filteredMusicFiles.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            searchQuery.isNotEmpty
                                ? "Sorry, no matching songs!"
                                : "No songs found. Retry?",
                            style: TextStyle(
                                fontSize: 18, color: theme.textTheme.bodyMedium!.color),
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredMusicFiles.length,
                        itemBuilder: (context, index) {
                          final musicFile = filteredMusicFiles[index];
                          bool isFavorite = musicVM.isFavorite(musicFile);

                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            child: Card(
                              color: theme.colorScheme.cardBackground,
                              child: ListTile(
                                leading: Icon(Icons.music_note_outlined,
                                    color: theme.colorScheme.musicIcon),
                                title: SizedBox(
                                  height: hi / 25,
                                  child: Marquee(
                                    text: musicFile.title,
                                    style: style(
                                      fontSize: hi / 50,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    blankSpace: 10,
                                    velocity: 30,
                                    startPadding: 10,
                                  ),
                                ),

                                onTap: () {
                                  musicVM.playMusic(
                                      musicFile, filteredMusicFiles, index);

                                  NavigationService.pushNamed(
                                    AppRoutes.musicPlayer,
                                    arguments: {
                                      'musicFile': musicFile,
                                      'playlist': filteredMusicFiles,
                                    },
                                  );
                                },

                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: Icon(Icons.playlist_add,
                                          color: theme.colorScheme.favoriteIconEmpty),
                                      onPressed: () => showPlaylistDialog(
                                          context, playlistVM, musicFile),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        isFavorite
                                            ? Icons.favorite
                                            : Icons.favorite_border,
                                        color:
                                            isFavorite ? theme.colorScheme.favoriteIconFilled : theme.colorScheme.favoriteIconEmpty,
                                      ),
                                      onPressed: () {
                                        musicVM.toggleFavoriteSong(musicFile);
                                        bool updated =
                                            musicVM.isFavorite(musicFile);

                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          SnackBar(
                                            backgroundColor: theme.colorScheme.favoriteIconFilled,
                                            behavior:
                                                SnackBarBehavior.floating,
                                            margin: const EdgeInsets.all(10),
                                            content: Text(
                                              updated
                                                  ? "Added to Favorites"
                                                  : "Removed from Favorites",
                                              style: TextStyle(
                                                  fontSize: hi / 50,
                                                  color: theme.textTheme.bodyLarge!.color),
                                            ),
                                            duration:
                                                const Duration(seconds: 1),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          )
        ],
      ),
    );
  }
}