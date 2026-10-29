# Z-PLAY architecture

Z-PLAY is an offline music player built with Flutter. The code is organised
**feature-first** and follows **MVVM** (model, view, view model):

- `lib/core/` holds everything two or more features share: the data layer, the
  three app-wide view models, shared models, theme, navigation and shared
  widgets.
- `lib/features/` holds one folder per screen area. A feature only contains
  what that feature uses.

State is shared with the `provider` package. Data is stored locally with Hive.
Songs come from the device (Android's music index plus a folder walk); the app
never goes online.

## Layers and data flow

```
 Device files / Android music index        Hive boxes on disk
          │                                      │
     SongScanner                            LibraryStore
          └──────────────┬───────────────────────┘
                         │
      LibraryRepository            PlaylistRepository        core/data/
                         │
   LibraryViewModel ── PlaylistViewModel ── PlayerViewModel  core/state/   (ChangeNotifier, provided app-wide)
                         │
   feature view models (plain classes, built per screen)     features/*/view_model/
                         │
   views (screens) ── widgets                                features/*/view/, */widgets/, core/widgets/
```

Each layer only talks to the one directly below it. Views and widgets never
touch a repository, the store, the scanner or Hive.

### How `main.dart` wires it

1. Bundled fonts only (`GoogleFonts.config.allowRuntimeFetching = false`) and
   the font licenses are registered.
2. Hive is initialised, the two adapters are registered, and five boxes are
   opened into one `LibraryStore` (see [Storage](#storage)).
3. The repositories are built on the store: `LibraryRepository` (also given a
   `SongScanner`) and `PlaylistRepository`.
4. The three shared view models are built and linked:
   - `LibraryViewModel(libraryRepository)`
   - `PlaylistViewModel(repository: playlistRepository, library: library)`;
     playlists resolve their songs against the library.
   - `library.onCatalogChanged = playlists.load`: playlists reload whenever a
     scan changes the library.
   - `PlayerViewModel(repository: libraryRepository, onPlayed: library.syncActivity)`:
     each play updates recently played and play counts.
5. All three are provided with `MultiProvider` around `ZPlayApp`.

## Folder tree

```
lib/
  main.dart
  core/
    app/
      app.dart                    ZPlayApp: MaterialApp, light/dark theme, system bar style
    data/
      library_store.dart          All Hive reads and writes
      song_scanner.dart           Android music index + folder walk → ScanResult
      library_repository.dart     Songs, favorites, play counts, settings, saved queue
      playlist_repository.dart    Playlist create, rename, edit, delete, name validation
    models/
      song_model.dart             Song (used by nearly everything)
      user_playlist_model.dart    UserPlaylist (in-memory playlist: id, name, songs, coverSeeds)
      playlist_model.dart + .g    Playlist (Hive, type id 1)
      music_file_model.dart + .g  MusicFile (Hive, type id 0)
      library_settings_model.dart, playback_snapshot_model.dart, scan_result_model.dart,
      song_group_model.dart, song_sort_model.dart, collection_kind_model.dart,
      collection_args_model.dart, repeat_mode_model.dart
    navigation/
      app_router.dart             AppRoutes: route names and generateRoute
      navigation_service.dart     Global navigator key, push helpers, backToMain()
    services/
      song_actions.dart           playFromList, playAll, shuffleAll, toggleFavorite,
                                  addToPlaylist (need a BuildContext for navigation/snackbars)
    state/
      library_view_model.dart     Songs, search, sort, folders/albums/artists, favorites,
                                  history, settings, scanning
      playlist_view_model.dart    Playlists, lookup by id or name
      player_view_model.dart      Playback (audioplayers), queue, repeat, shuffle, speed,
                                  sleep timer, next song
      playback_queue.dart         Queue order, shuffle and reorder logic
    theme/
      app_colors.dart             AppColors: every color token and gradient
      app_tokens.dart             AppTokens: per-theme colors (ThemeExtension)
      app_theme.dart              AppTheme.dark() / AppTheme.light()
      app_radii.dart, app_spacing.dart, app_sizes.dart
      fade_up_page_transition.dart, slider_shapes.dart
    utils/
      format_utils.dart           Clock, durations, track counts, countdown, speed labels
      text_utils.dart             Artist initial, album artist, short storage path
      layout_utils.dart           Tab list padding, cover grid cell height
    widgets/                      Shared widgets (one public widget per file):
      gradient_scaffold, cover_art, cover_collage, album_cover, artist_avatar,
      song_tile, song_sliver_list, equalizer_bars, song_menu_sheet,
      add_to_playlist_sheet, add_to_playlist_row, playlist_editor_sheet,
      primary_button, ghost_button, pill_button_label, round_icon_button,
      pill_chip, gradient_checkbox, dashed_box, app_sheet, snack_pill,
      empty_state, logo_mark, wordmark, detail_top_bar, collection_header,
      play_shuffle_buttons, marquee_text
  features/
    splash/       view/splash_view.dart
                  view_model/splash_view_model.dart
                  widgets/loading_stripe.dart
    shell/        view/shell_view.dart
                  model/nav_bar_item_model.dart
                  widgets/floating_nav_bar.dart, mini_player.dart, shell_bottom_bars.dart
    library/      view/library_view.dart
                  view_model/library_tabs_view_model.dart
                  widgets/library_header, library_search_field, rotating_search_hint,
                          library_tab_chips,
                          library_count_row, sort_button, sort_sheet, songs_tab,
                          folders_tab, folder_row, albums_tab, album_card,
                          artists_tab, artist_card, tab_empty_state
    collection/   view/collection_view.dart
                  view_model/collection_view_model.dart
                  widgets/collection_cover.dart
    favorites/    view/favorites_view.dart
                  view_model/favorites_view_model.dart
                  widgets/favorites_header.dart, favorites_summary_card.dart
    playlists/    view/playlists_view.dart, playlist_detail_view.dart
                  view_model/playlists_view_model.dart, playlist_detail_view_model.dart
                  widgets/playlists_header, playlist_grid, playlist_card,
                          playlist_detail_header, confirm_dialog
    player/       view/player_view.dart
                  view_model/player_screen_view_model.dart
                  widgets/player_top_bar, now_playing_cover, player_title_row,
                          seek_bar, playback_controls, toggle_icon_button,
                          big_play_button, player_error_line, player_action_bar,
                          action_bar_item, sleep_countdown_label, up_next_pill,
                          speed_sheet, sleep_timer_sheet, sleep_countdown_card
    queue/        view/queue_view.dart
                  view_model/queue_view_model.dart
                  widgets/queue_header, queue_section_label, now_playing_card,
                          queue_section, queue_row
    history/      view/history_view.dart
                  model/segment_option_model.dart
                  view_model/history_view_model.dart
                  widgets/history_header, segmented_pill, rank_number, count_pill
    settings/     view/settings_view.dart
                  view_model/settings_view_model.dart
                  widgets/settings_section_label, settings_card, setting_row,
                          chevron_icon, toggle_switch, hidden_folders_section,
                          settings_footer
    info/         view/info_view.dart
                  model/info_page_model.dart      (About, Privacy, Terms text)
                  widgets/info_header.dart, info_section_card.dart
    not_found/    view/not_found_view.dart
test/
  playback_queue_test.dart        Queue order, shuffle, repeat, play next
  playlist_rename_test.dart       Rename, edit songs and duplicate names keep the playlist id
  hive_adapters_test.dart         Hive type ids and a playlist round trip from disk
```

## Features

| Feature | Screen(s) | Feature view model | Shared view models it uses | Feature model |
|---|---|---|---|---|
| splash | SplashView | SplashViewModel | Library, Playlist, Player | – |
| shell | ShellView | – | Player | NavBarItem |
| library | LibraryView | LibraryTabsViewModel | Library, Player | – |
| collection | CollectionView | CollectionViewModel | Library | – |
| favorites | FavoritesView | FavoritesViewModel | Library | – |
| playlists | PlaylistsView, PlaylistDetailView | PlaylistsViewModel, PlaylistDetailViewModel | Playlist | – |
| player | PlayerView | PlayerScreenViewModel | Player, Library | – |
| queue | QueueView | QueueViewModel | Player | – |
| history | HistoryView | HistoryViewModel | Library, Player | SegmentOption |
| settings | SettingsView | SettingsViewModel | Library | – |
| info | InfoView | – (static content) | – | InfoPage, InfoSection, InfoKind |
| not_found | NotFoundView | – | – | – |

`shell` hosts the four tabs (Library, Favorites, Playlists, Settings) in an
`IndexedStack`, so each tab keeps its state. The router passes the tab pages
in, so the shell doesn't import the features it shows.

## Routes

Defined in `core/navigation/app_router.dart`. The router is the only file in
`core/` that imports feature screens.

| Route | Screen | Argument |
|---|---|---|
| `/` | SplashView | – |
| `/main` | ShellView (Library, Favorites, Playlists, Settings tabs) | – |
| `/player` | PlayerView | – |
| `/queue` | QueueView | – |
| `/collection` | CollectionView | `CollectionArgs` (kind, id, title) |
| `/playlist` | PlaylistDetailView | playlist name |
| `/recent` | HistoryView (Recently played) | – |
| `/most-played` | HistoryView (Most played) | – |
| `/about`, `/privacy`, `/terms` | InfoView | – |
| anything else | NotFoundView | – |

## View models

There are two kinds.

1. **Shared view models** (`core/state/`) are `ChangeNotifier`s created once
   in `main.dart`. They own the app's state, call the repositories, and notify
   listeners when something changes.
2. **Feature view models** (`features/*/view_model/`) are plain classes, not
   `ChangeNotifier`s. They hold no state of their own: they turn shared state
   into what one screen shows (labels, counts, sections, which tab shows
   what) and forward actions to the shared view models.

Where feature view models are built:

- **In the screen's `build()`** from the shared view models it watches, e.g.
  `QueueViewModel(context.watch<PlayerViewModel>())`. The screen already
  rebuilds when that shared view model notifies, so the feature view model
  needs no provider of its own.
- **`SplashViewModel`** is built once in `initState`, because the library load
  must run only once.
- **`PlayerScreenViewModel`** is also built by the player widgets that rebuild
  on their own: the sleep timer sheet, the speed sheet, and the sleep countdown
  card and label (which tick every second).

Some widgets watch a shared view model directly so only they rebuild: the
Library's Songs tab watches the player, and the Now Playing title row watches
the library for the favorite heart.

Short-lived UI state stays in a widget's `State`: text and tab controllers,
animation controllers (Lottie, equalizer, loading stripe), the play button's
pressed flag, the selected history segment, and the search hint's rotation timer.

## Rules

- **Screens only call widgets.** A file in `view/` defines just the screen and
  its `State`. Every other widget lives in the feature's `widgets/` folder or
  in `core/widgets/`.
- **One public widget per file** in `widgets/` folders; small private helpers
  may share the file. A sheet or dialog file also holds its `show…()` function.
- **Logic lives in view models,** never in views or widgets.
- **Shared code lives in `core/`.** Anything used by two or more features goes
  there, and no feature imports another feature's folder.
- **Comments** use `//` only, never `///`, and explain why, not what.
- **Numbers:** sizes, radii, durations and opacities repeated across files are
  named in `AppSizes`, `AppRadii` or `AppSpacing`. One-off values are named
  `static const` fields in the widget that uses them. Padding and gap values
  on the 4-point spacing grid stay inline.
- **Colors** come from `AppTokens.of(context)` (per theme) or `AppColors`
  (brand colors and gradients), never hard-coded in widgets.

## Naming

- Files and folders are `snake_case`. No file, folder or class keeps the old
  `Z` prefix; the brand class `ZPlayApp` is the only exception.
- Screens are `<name>_view.dart`, view models `<name>_view_model.dart`, data
  classes `<name>_model.dart`, and widgets use a clear noun (`song_tile.dart`,
  `mini_player.dart`).
- Widget names avoid clashing with Flutter's own: `ToggleSwitch` (not
  `Switch`), `PillChip` (not `Chip`), `AppSheet` (not `BottomSheet`),
  `SnackPill` (not `SnackBar`), `GradientCheckbox` (not `Checkbox`).

## Storage

`LibraryStore` is the only class that reads or writes Hive. It opens five
boxes:

| Box | Holds |
|---|---|
| `favorites` | Favorite song paths |
| `playlistsBox` | Playlists (`Playlist` with `MusicFile` songs) |
| `playCountsBox` | Play count per song path |
| `preferences` | Settings, recently played, and the saved queue with its position and speed |
| `recentlyPlayedBox` | Recently played from older versions; only read when `preferences` has no recent list yet |

The Hive adapters in `core/models/*.g.dart` use type ids 0 (`MusicFile`) and
1 (`Playlist`). `test/hive_adapters_test.dart` locks those ids, because
changing them would make existing installs' playlists unreadable.
