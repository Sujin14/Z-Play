import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/permissions/permissions_handler.dart';
import '../../../../constants/themes.dart';
import '../viewmodels/music_viewmodel.dart';
import '../viewmodels/playlist_viewmodel.dart';
import '../widgets/favorites/loading_indicator.dart';
import '../widgets/home/empty_music_view.dart';
import '../widgets/home/music_list.dart';
import '../widgets/home/search_bar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  String searchQuery = '';
  final TextEditingController searchController = TextEditingController();
  bool isSearchActive = false;
  final FocusNode searchFocusNode = FocusNode();
  late final AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 250));
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
    _fadeController.dispose();
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
            .where((m) =>
                m.title.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text("Z-PLAY",
            style: style(
                fontSize: hi / 30, color: theme.textTheme.bodyLarge!.color)),
        centerTitle: true,
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
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              theme.colorScheme.gradientStart,
              theme.colorScheme.gradientEnd
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              if (isSearchActive)
                SearchBarWidget(
                  searchController: searchController,
                  searchFocusNode: searchFocusNode,
                  onChanged: (q) => setState(() => searchQuery = q),
                ),
              Expanded(
                child: musicVM.isLoading
                    ? const LoadingIndicator()
                    : filteredMusicFiles.isEmpty
                        ? EmptyMusicView(searchQuery: searchQuery)
                        : MusicList(
                            filteredMusicFiles: filteredMusicFiles,
                            musicVM: musicVM,
                            playlistVM: playlistVM,
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
