import 'package:flutter/material.dart';
import 'package:marquee/marquee.dart';
import 'package:musicplayer/view/player/player_page.dart';
import 'package:musicplayer/view_model/providers/music_provider.dart';
import 'package:musicplayer/view_model/playlist/playlist_creation.dart';
import 'package:musicplayer/view_model/providers/playlist_provider.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String searchQuery = '';
  TextEditingController searchController = TextEditingController();
  bool isSearchActive = false;
  FocusNode searchFocusNode = FocusNode();

  @override
  void dispose() {
    searchController.dispose();
    searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MusicProvider>().requestStoragePermissionAndFetchFiles();
    });
  }

  @override
  Widget build(BuildContext context) {
    final hi = MediaQuery.of(context).size.height;
    final musicProvider = Provider.of<MusicProvider>(context);
    final filteredMusicFiles = searchQuery.isEmpty
        ? musicProvider.musicFiles
        : musicProvider.musicFiles
            .where((musicFile) => musicFile.title
                .toLowerCase()
                .contains(searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Z-PLAY',
          style: TextStyle(
            fontSize: hi / 30,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(isSearchActive ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                isSearchActive = !isSearchActive;
                if (isSearchActive) {
                  FocusScope.of(context).requestFocus(searchFocusNode);
                } else {
                  FocusScope.of(context).unfocus();
                  searchQuery = '';
                  searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          if (isSearchActive)
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: 80.0,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  focusNode: searchFocusNode,
                  controller: searchController,
                  onChanged: (query) {
                    setState(() {
                      searchQuery = query;
                    });
                  },
                  onSubmitted: (query) {
                    setState(() {
                      isSearchActive = false;
                      FocusScope.of(context).unfocus();
                    });
                  },
                  decoration: const InputDecoration(
                    hintText: 'Search music files...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10)),
                    ),
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
            ),
          Expanded(
            child: musicProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : filteredMusicFiles.isEmpty && searchQuery.isNotEmpty
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Text(
                            'Sorry, no matching songs!',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                        ),
                      )
                    : filteredMusicFiles.isEmpty
                        ? Center(
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: TextButton(
                                child: const Text('Retry'),
                                onPressed: () => context
                                    .read<MusicProvider>()
                                    .requestStoragePermissionAndFetchFiles(),
                              ),
                            ),
                          )
                        : ListView.builder(
                            itemCount: filteredMusicFiles.length,
                            itemBuilder: (context, index) {
                              final musicFile = filteredMusicFiles[index];
                              bool isFavorite =
                                  musicProvider.isFavorite(musicFile);
                              return Padding(
                                padding:
                                    const EdgeInsets.fromLTRB(8.0, 0, 8.0, 0),
                                child: Card(
                                  color:
                                      const Color.fromARGB(255, 101, 97, 119),
                                  child: ListTile(
                                    leading: const Icon(Icons.music_note,
                                        color: Color(0xFF2196F3)),
                                    title: SizedBox(
                                      height: hi / 25,
                                      width: double.infinity,
                                      child: Marquee(
                                        text: musicFile.title,
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: hi / 50,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        scrollAxis: Axis.horizontal,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        blankSpace: 10,
                                        velocity: 30.0,
                                        startPadding: 10.0,
                                        accelerationDuration:
                                            Duration(seconds: 5),
                                      ),
                                    ),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => MusicPlayer(
                                            musicFile: musicFile,
                                            playlist: filteredMusicFiles,
                                          ),
                                        ),
                                      );
                                    },
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.playlist_add,
                                              color: Colors.white),
                                          onPressed: () {
                                            showPlaylistDialog(
                                                context,
                                                Provider.of<PlaylistProvider>(
                                                    context,
                                                    listen: false),
                                                musicFile);
                                          },
                                        ),
                                        IconButton(
                                          icon: Icon(
                                            isFavorite
                                                ? Icons.favorite
                                                : Icons.favorite_border,
                                            color: isFavorite
                                                ? const Color(0xFFF44336)
                                                : Colors.white,
                                          ),
                                          onPressed: () {
                                            musicProvider
                                                .toggleFavorite(musicFile);
                                            bool updatedFavoriteStatus =
                                                musicProvider
                                                    .isFavorite(musicFile);
                                            ScaffoldMessenger.of(context)
                                                .showSnackBar(
                                              SnackBar(
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                margin:
                                                    const EdgeInsets.all(10),
                                                backgroundColor: Colors.red,
                                                content: Text(
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: hi / 50),
                                                  updatedFavoriteStatus
                                                      ? '${musicFile.title.length > 25 ? '${musicFile.title.substring(0, 25)}...' : musicFile.title} added to Favorites'
                                                      : '${musicFile.title.length > 25 ? '${musicFile.title.substring(0, 25)}...' : musicFile.title} removed from Favorites',
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
          ),
        ],
      ),
    );
  }
}
