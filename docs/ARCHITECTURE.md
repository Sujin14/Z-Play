# Z Play architecture

Z Play is an offline music player built with Flutter. The code is organised
**feature-first** and follows **MVVM** (model, view, view model):

- `lib/core/` holds everything two or more features share: the data layer, the
  three app-wide view models, shared models, theme, navigation and shared
  widgets.
- `lib/features/` holds one folder per screen area. A feature only contains
  what that feature uses.

State is shared with the `provider` package. Data is stored locally with Hive.
Songs come from the device: Android's music index plus a folder walk, or the
iOS music library. The app never goes online.

## Layers and data flow

```
 Device files / music index (Android, iOS) Hive boxes on disk
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
2. `AppInfoService.load()` reads the app version once (via `package_info_plus`),
   so the Settings footer and About page never wait for it.
   `PlatformCapabilities.current()` records what the platform supports.
3. Hive is initialised, the two adapters are registered, and five boxes are
   opened into one `LibraryStore` (see [Storage](#storage)).
4. The repositories are built on the store: `LibraryRepository` (also given a
   `SongScanner` and a `DeviceMediaPermissionService`) and `PlaylistRepository`.
5. The three shared view models are built and linked:
   - `LibraryViewModel(libraryRepository)`
   - `PlaylistViewModel(repository: playlistRepository, library: library)`;
     playlists resolve their songs against the library.
   - `library.onCatalogChanged = playlists.load`: playlists reload whenever a
     scan changes the library.
   - `AudioService.init(builder: MediaSessionHandler.new, config: MediaSessionHandler.config)`
     starts the media session first; after the player is built,
     `session.attach(player)` connects them, so neither builds the other.
   - `PlayerViewModel(repository: libraryRepository, onPlayed: library.syncActivity, engine: JustAudioEngine())`:
     each play updates recently played and play counts.
6. `AppInfoService` and `PlatformCapabilities` (plain `Provider`s) and the three view models
   (`ChangeNotifierProvider`) are provided with `MultiProvider` around `ZPlayApp`.

## Folder tree

```
lib/
  main.dart
  core/
    app/
      app.dart                    ZPlayApp: MaterialApp, light/dark theme, system bar style
      app_name.dart               appName = 'Z Play', the only user-facing spelling of the name
    data/
      library_store.dart          All Hive reads and writes
      song_scanner.dart           Music index (Android, iOS) + folder walk (not on iOS) → ScanResult
      library_repository.dart     Songs, favorites, play counts, settings, saved queue
      playlist_repository.dart    Playlist create, rename, edit, delete, name validation
    models/
      song_model.dart             Song (used by nearly everything)
      user_playlist_model.dart    UserPlaylist (in-memory playlist: id, name, songs, coverSeeds)
      playlist_model.dart + .g    Playlist (Hive, type id 1)
      music_file_model.dart + .g  MusicFile (Hive, type id 0)
      library_settings_model.dart, playback_snapshot_model.dart, scan_result_model.dart,
      media_access_model.dart (granted / denied / permanentlyDenied),
      playback_track_model.dart, track_change_model.dart, playback_error_model.dart
                                  (what PlaybackEngine takes and reports),
      song_group_model.dart, song_sort_model.dart, collection_kind_model.dart,
      collection_args_model.dart, repeat_mode_model.dart
    navigation/
      app_router.dart             AppRoutes: route names and generateRoute
      navigation_service.dart     Global navigator key, push helpers, backToMain()
      now_playing_route.dart      NowPlayingRoute: Now Playing grows out of / minimizes into
                                  the mini player; swipe-down and predictive back
      mini_player_anchor.dart     MiniPlayerAnchor: the mini player's GlobalKey, its rect
                                  (live or computed fallback), bar geometry, cover Hero tag
    services/
      song_actions.dart           playFromList, playAll, shuffleAll, toggleFavorite,
                                  addToPlaylist (need a BuildContext for navigation/snackbars)
      app_info_service.dart       App version from pubspec.yaml ("1.0.0+3"), loaded at startup
      media_permission_service.dart  MediaPermissionService (interface) and the device version:
                                  asks for music access and waits for the answer
      platform_capabilities.dart  PlatformCapabilities: supportsFolders and
                                  hasPlaybackNotification (both false on iOS)
      playback_engine.dart        PlaybackEngine (interface): a list of tracks the platform plays
                                  through by itself (setQueue, play, pause, stop, seek, seekToIndex,
                                  setSpeed, setRepeat, insert/remove/moveTrack, replaceAround;
                                  playing, position, duration, trackChanges, queueCompleted, errors)
      just_audio_engine.dart      JustAudioEngine: the only file that imports just_audio and
                                  audio_session (music session, file vs URL source)
      playback_controls.dart      PlaybackControls (interface): what the media session may do
                                  (resume, pause, next, previous, seek, seekBy) and read
                                  (song, playing, duration, position, speed); PlayerViewModel
                                  implements it
      media_session_handler.dart  MediaSessionHandler (audio_service): Android notification and
                                  media buttons → PlaybackControls; publishes MediaItem and
                                  PlaybackState; holds the notification config
      background_save_observer.dart  BackgroundSaveObserver: saves playback at once when the app
                                  goes to the background or is detached (registered in main.dart)
    state/
      library_view_model.dart     Songs, search, sort, folders/albums/artists, favorites,
                                  history, settings, scanning
      playlist_view_model.dart    Playlists, lookup by id or name
      player_view_model.dart      Playback (through PlaybackEngine), queue, repeat, shuffle, speed,
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
      support_contact.dart        supportEmail: the only copy of the support address in lib/
    widgets/                      Shared widgets (one public widget per file):
      gradient_scaffold, cover_art, cover_collage, album_cover, artist_avatar,
      song_tile, song_sliver_list, equalizer_bars, song_menu_sheet,
      add_to_playlist_sheet, add_to_playlist_row, playlist_editor_sheet,
      primary_button, ghost_button, pill_button_label, round_icon_button,
      pill_chip, gradient_checkbox, dashed_box, app_sheet, snack_pill,
      empty_state, logo_mark, wordmark, detail_top_bar, collection_header,
      play_shuffle_buttons, marquee_text, cover_hero, minimize_drag_area
  features/
    splash/       view/splash_view.dart
                  view_model/splash_view_model.dart
                  widgets/splash_animation.dart, splash_wordmark.dart
    shell/        view/shell_view.dart
                  model/nav_bar_item_model.dart
                  widgets/floating_nav_bar.dart, mini_player.dart, shell_bottom_bars.dart
    library/      view/library_view.dart
                  model/library_tab_model.dart    (LibraryTab: songs, folders, albums, artists)
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
                          chevron_icon, toggle_switch, settings_footer
    hidden_folders/ view/hidden_folders_view.dart
                  view_model/hidden_folders_view_model.dart
                  widgets/hidden_folders_header, hidden_folder_list, hidden_folder_row
    help/         view/help_view.dart
                  model/faq_item.dart, help_content.dart   (page text and the six FAQs)
                  view_model/help_view_model.dart
                  widgets/help_header, faq_tile, help_contact_card
    info/         view/info_view.dart
                  model/info_page_model.dart      (About, Privacy, Terms text)
                  widgets/info_header.dart, info_section_card.dart
    not_found/    view/not_found_view.dart
test/
  playback_queue_test.dart        Queue order, shuffle, repeat, play next
  playback_store_test.dart        Saved playback state round trip in Hive; old saves load with
                                  repeat and shuffle off
  media_session_handler_test.dart MediaSessionHandler on FakePlaybackControls: actions, headset
                                  buttons, controls and compact indices, MediaItem without
                                  artwork, no republish on position ticks, swipe-away, config
  player_view_model_test.dart     PlayerViewModel on a FakePlaybackEngine: starts, the platform
                                  moving on, repeat, end of queue and play after it, queue edits
                                  and shuffle mirrored without a restart, both sleep modes, stale
                                  starts, errors and skipping, restore (repeat, shuffle, old data),
                                  seekBy, when saves happen and coalescing, swipe-away keeps state
  playlist_rename_test.dart       Rename, edit songs and duplicate names keep the playlist id
  hive_adapters_test.dart         Hive type ids and a playlist round trip from disk
  splash_view_model_test.dart     Opens only when animation and library are both done; failure,
                                  reduced-motion and safety fallbacks
  splash_view_test.dart           The splash shows the Lottie and the wordmark (appName), on the
                                  dark gradient in both themes, without overflow on a short screen
  media_access_test.dart          Granting in the prompt goes straight on to the scan; denied and
                                  permanently denied show the allow-access state with Open settings
  platform_capabilities_test.dart No Folders tab where folders aren't supported
  settings_view_model_test.dart   Rescan storage subtitle: Android wording, or "Refresh your music
                                  library" on iOS
  splash_startup_test.dart        Cold start with the real LibraryViewModel: no build-phase error,
                                  splash hands over to the shell
  app_info_service_test.dart      Version formatting with a fake package info loader
  help_content_test.dart          7 FAQs on Android, 6 on iOS; iOS answers never mention hidden
                                  folders; the background-playback FAQ and its iOS variant; no
                                  email address in lib/ outside support_contact.dart
  info_page_model_test.dart       About: the service's version and the What you can do list per platform;
                                  Privacy and Terms background-playback text; support email; dates
  now_playing_route_test.dart     750ms each way; clip starts on the mini player rect, ends full
                                  screen, closes back onto it; content fade stagger; reduced
                                  motion uses the fade
```

## Features

| Feature | Screen(s) | Feature view model | Shared view models it uses | Feature model |
|---|---|---|---|---|
| splash | SplashView | SplashViewModel | Library, Playlist, Player | – |
| shell | ShellView | – | Player | NavBarItem |
| library | LibraryView | LibraryTabsViewModel | Library, Player (+ PlatformCapabilities) | LibraryTab |
| collection | CollectionView | CollectionViewModel | Library | – |
| favorites | FavoritesView | FavoritesViewModel | Library | – |
| playlists | PlaylistsView, PlaylistDetailView | PlaylistsViewModel, PlaylistDetailViewModel | Playlist | – |
| player | PlayerView | PlayerScreenViewModel | Player, Library | – |
| queue | QueueView | QueueViewModel | Player | – |
| history | HistoryView | HistoryViewModel | Library, Player | SegmentOption |
| settings | SettingsView | SettingsViewModel | Library (+ AppInfoService, PlatformCapabilities) | – |
| hidden_folders | HiddenFoldersView | HiddenFoldersViewModel | Library | – |
| help | HelpView | HelpViewModel | – (+ PlatformCapabilities) | FaqItem, HelpContent |
| info | InfoView | – (static content; About gets the version from AppInfoService) | – | InfoPage, InfoSection, InfoBlock (InfoParagraph, InfoBullets), InfoAction, InfoKind |
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
| `/player` | PlayerView in a `NowPlayingRoute` (see [Now Playing transition](#now-playing-transition)) | – |
| `/queue` | QueueView | – |
| `/collection` | CollectionView | `CollectionArgs` (kind, id, title) |
| `/playlist` | PlaylistDetailView | playlist name |
| `/recent` | HistoryView (Recently played) | – |
| `/most-played` | HistoryView (Most played) | – |
| `/about`, `/privacy`, `/terms` | InfoView | – |
| `/hidden-folders` | HiddenFoldersView (opened from Settings) | – |
| `/help` | HelpView (opened from Settings, "Help & FAQ") | – |
| anything else | NotFoundView | – |

## Playback engine

`PlayerViewModel` plays through `PlaybackEngine` (`core/services/`), wired in
`main.dart` as `JustAudioEngine`; tests use `FakePlaybackEngine`.

- **The platform moves on by itself.** The engine holds the whole queue
  (just_audio `setAudioSources`), so the next song starts natively and
  gaplessly. `PlaybackQueue` stays the single source of truth for order; the
  engine's list mirrors it. The engine reports a native move as a
  `TrackChange` with `automatic: true`, and `PlayerViewModel` then updates
  `PlaybackQueue`, counts the play (not for repeat one), resets the 5-second
  save marker and notifies.
- **Queue edits keep the song playing.** Add → `insertTrack`; remove another
  song → `removeTrack`; reorder → `moveTrack`; play next and shuffle →
  `replaceAround` (everything but the current song is replaced). Removing
  the current song reloads the list at the next one.
- **Repeat** maps to the engine's loop modes; **speed** is a player setting
  the engine keeps across songs.
- **"End of track" sleep** trims the engine's list to the current song (with
  loop off) so it stops at the end; finishing, cancelling or starting the
  minute timer restores the list and repeat.
- **Errors**, at the start or mid-song, show "Cannot play <title>." and skip
  to the next song; a full pass of failures stops.
- **After the queue ends**, play starts the last song again from 0.
- **`seekBy`** (for the 10-second skips): rewind stops at 0; forward stops
  `seekEndMargin` (50 ms) before the end so the song finishes by itself, and
  is ignored while the length is unknown.
- **Saved playback state** (`PlaybackSnapshot`, `preferences` box, plain
  keys): `queue` (playing order), `queueIndex`, `positionMs`, `speed`,
  `queueOriginal` (the order before shuffling; empty when not shuffled),
  `shuffle` and `repeat` (`off`, `all`, `one`). Saves from before the last
  three load as shuffle off and repeat off. Restore rebuilds both orders
  (`PlaybackQueue.restored`), keeps the saved song current even if earlier
  songs are gone, and gives the engine the list, the loop mode and the
  speed without playing.
- **When it is saved:** at once on pause, a song change (by the app or the
  platform), the end of the queue, every 5 s of playback, and when the app
  goes to the background or is detached (`BackgroundSaveObserver`). Queue
  edits, shuffle, repeat and speed changes are coalesced and written 300 ms
  after the last one. Swiping the paused notification away pauses (which
  saves) and never clears the saved state.
- **Audio session:** `AudioSessionConfiguration.music()`. just_audio's own
  handling (`handleInterruptions`, on by default) pauses on a call or Siri
  and resumes afterwards only if it was playing, and pauses when headphones
  are unplugged.

## Background playback (Android)

audio_service runs a media playback foreground service while music plays.
`MediaSessionHandler` (`core/services/`) is its `AudioHandler`; it talks to
`PlayerViewModel` only through `PlaybackControls`.

- **Notification:** title, artist and album; no artwork; the monochrome
  `drawable/ic_notification` icon. Compact: previous, play/pause, next.
  Expanded: rewind 10 s, previous, play/pause, next, forward 10 s. No close
  button. Channel `com.sujin.musicplayer.playback` ("Playback"; audio_service
  creates it at low importance, so no sound or vibration).
- **Actions:** play → `resume`, pause, next, previous (3-second restart
  rule), seek, forward/rewind → `seekBy(±10 s)`. Headset and Bluetooth
  buttons arrive through the same media session (a single press toggles).
- **State:** a `PlaybackState` (ready, playing or paused, position, speed)
  is published whenever `PlayerViewModel` notifies: play/pause, a new song,
  speed, and seeks (`seek` notifies for this). Position ticks are never
  republished; the system advances the bar from the last position and the
  speed.
- **Stopping:** pausing takes the service out of the foreground
  (`androidStopForegroundOnPause`), so the notification can be swiped away.
  Swiping it away pauses and makes the session idle; the saved queue is kept
  (it does not call `PlayerViewModel.stop()`, which would clear it).
  Swiping the app out of recents leaves playback running.
- **Android setup:** `MainActivity` extends `AudioServiceActivity`; the
  manifest declares `WAKE_LOCK`, `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, audio_service's `AudioService`
  (`foregroundServiceType="mediaPlayback"`) and `MediaButtonReceiver`.
  `POST_NOTIFICATIONS` is not requested: media-session notifications are
  exempt on Android 13+.
  The release APK declares exactly: `READ_MEDIA_AUDIO`,
  `READ_EXTERNAL_STORAGE` (maxSdkVersion 32), `WAKE_LOCK`,
  `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, and androidx's
  internal `<applicationId>.DYNAMIC_RECEIVER_NOT_EXPORTED_PERMISSION`. No
  `INTERNET` (only the debug and profile manifests add it, for development).
  `ACCESS_NETWORK_STATE`, which ExoPlayer (media3, inside just_audio) merges
  in, is removed with `tools:node="remove"`; media3 catches the
  `SecurityException` and reports an unknown network type, which doesn't
  matter for files on the device.
- **Audio focus and unplugging** stay with just_audio and audio_session;
  audio_service doesn't handle either.

## Now Playing transition

Every way of opening Now Playing (the mini player, tapping a song, Play all,
Shuffle) pushes `/player` through `NavigationService`, and the router wraps
`PlayerView` in `NowPlayingRoute`.

- **Morph.** The page is laid out once at full size. A `ClipRRect` with
  `NowPlayingClipper` animates from the mini player's rect (22px radius) to
  the full screen (0 radius) over 750ms (`Curves.easeInOutCubic`), and back
  over 750ms on close. The rect, the radius and the cover Hero share that
  curve. The fades are intervals of the route's linear progress (elapsed
  time): the gradient fill (`AppTokens.background`) shows in the first 15%,
  so the rect is visible from the start; the content fades in during 35–85%
  of opening and out during the first 40% of closing; the cover's Lottie
  appears in the last 20%. Only the clip and the opacities change per frame,
  so nothing in the page rebuilds. With `MediaQuery.disableAnimations` the
  route is a 150ms fade instead.
- **Where it grows from.** `MiniPlayerAnchor.rectIn` returns the mini
  player's live rect, read through `MiniPlayerAnchor.key` (set on the mini
  player). When the mini player isn't laid out (the first song is starting),
  it computes where the mini player will sit from the screen size, the safe
  area and the bar geometry, which `ShellBottomBars` also lays itself out
  with. The rect is always clamped to the screen.
- **Cover.** `CoverHero` (tag `MiniPlayerAnchor.coverHeroTag`) wraps the
  mini player's cover and the large cover. Its shuttle scales the art without
  stretching and moves the corner radius between the two covers'. Only the
  art flies; the Lottie stays on the page, so it never restarts.
- **Swipe down.** `MinimizeDragArea` wraps the top bar and the cover only, so
  the seek bar and sliders never start a dismissal. It claims a drag only
  when the drag goes down and the page is at its scroll start. The drag drives
  the route's controller linearly (the clip's top edge follows the finger);
  past 25% of the height or a downward fling minimizes, otherwise it springs
  back. Either way the rest runs for the remaining fraction of the
  750ms route duration, at least 250ms.
- **Back.** The chevron and system back pop the route, which plays the close
  animation. Android predictive back events (only sent when the manifest opts
  in) drive the same controller.

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
  must run only once. Its `start()` runs in a post-frame callback, because the
  library load notifies listeners straight away and that isn't allowed while
  the first frame is being built. Work that notifies is never started
  directly from `initState`. It is the one feature view model with state of its own
  (see [Splash](#splash)).
- **`PlayerScreenViewModel`** is also built by the player widgets that rebuild
  on their own: the sleep timer sheet, the speed sheet, and the sleep countdown
  card and label (which tick every second).

Some widgets watch a shared view model directly so only they rebuild: the
Library's Songs tab watches the player, and the Now Playing title row watches
the library for the favorite heart.

Short-lived UI state stays in a widget's `State`: text and tab controllers,
animation controllers (Lottie, equalizer, splash Lottie), the play button's
pressed flag, the selected history segment, the search hint's rotation timer,
and which Help answer is open (`HelpViewModel` turns that index into the
next one; only one answer is open at a time).

## Info pages and support contact

- `InfoPage` holds a title, an optional `lastUpdated` line (Privacy and Terms)
  and a list of `InfoSection`s. A section has an optional heading (none for an
  intro card), an ordered list of `InfoBlock`s (`InfoParagraph` or
  `InfoBullets`), and an optional `InfoAction`. The only action is
  `licenses`, which `InfoView` turns into `showLicensePage` with the app
  version.
- The About page's Version section comes from `AppInfoService`, never a
  hard-coded string.
- The support address lives only in `core/utils/support_contact.dart`
  (`supportEmail`). The info text and the Help page both read it;
  `help_content_test.dart` fails if any other file in `lib/` contains an
  email address.

## Splash

The splash shows `assets/json/splash.json` with the app name 24px below it,
as one group centered on the **dark** page gradient whatever the app theme
(the splash overrides `AppTokens` with `AppTokens.dark`), so it matches the
native launch color and the Lottie's white strokes stay visible. The shell
after it uses the chosen theme; the normal page fade covers the change. The
splash also asks for light status bar icons and a `#031109` navigation bar
with light icons, through its own `AnnotatedRegion`,
nested inside the app's theme-based one, so the theme's style returns as soon
as the splash leaves the tree. The
Lottie is the smallest of 70% of the screen width, 45% of its height and 360
logical px, and the group scales down (`FittedBox`) rather than overflow on
very short screens. `SplashWordmark` shows `appName` in Sora 28/800
in the dark theme's text color; it fades in with an 8px upward slide over
600ms, starting 300ms in (shown at once with reduced motion). Its space is
reserved from the first frame, so the Lottie never moves, and the fade has no
effect on when the splash leaves. `SplashAnimation` plays the Lottie once and
reports loaded, finished or failed; `SplashViewModel` decides when to leave:

- It opens the shell once the animation has finished **and** the library has
  loaded (library, then playlists, then the saved queue), whichever comes
  last. The library load starts at once and doesn't wait for the animation.
- If the Lottie fails to load, the animation counts as finished after 1s.
- With `MediaQuery.disableAnimations`, the last frame is shown still for
  600ms.
- If the animation reports nothing at all, it counts as finished after 6s,
  so the splash can't get stuck.

The native launch screens (Android `launch_background` and window
background, iOS `LaunchScreen.storyboard`) are a plain `#031109`, the dark
gradient's base color, in both themes. On Android 12+ the system splash
(`values-v31`, `values-night-v31`) uses the same color, and its icon is that
color too, so only the plain dark screen shows: the launcher icon has no
adaptive foreground to use there.

## Platforms

- **Music access.** `LibraryRepository` asks `MediaPermissionService` before a
  scan and waits for the answer, then passes it to `SongScanner`. On iOS the
  device service uses permission_handler (`Permission.mediaLibrary`; the
  Podfile enables `PERMISSION_MEDIA_LIBRARY=1`), because on_audio_query's iOS
  request returns before the user answers. Android keeps on_audio_query's
  `checkAndRequest`. `LibraryViewModel.access` holds the result; when access
  is denied and nothing was found, the Songs tab's error state offers
  "Try again" and "Open settings" (`openAppSettings()`).
- **Folders.** `PlatformCapabilities.supportsFolders` is false on iOS. View
  models read it: the Library has no Folders tab, Settings has no Hidden
  folders row (so `/hidden-folders` can't be reached), and Help leaves out
  the folder question (6 FAQs instead of 7). FAQs whose answer mentions
  folders carry an `answerWithoutFolders` that `HelpViewModel` shows instead.
- **Playback notification.** `PlatformCapabilities.hasPlaybackNotification`
  is false on iOS (controls live on the lock screen and in Control Center).
  FAQs that describe the notification carry an `answerWithoutNotification`
  for iOS, chosen by `HelpViewModel` the same way.
- **iOS.** `SongScanner` reads the iOS music library through on_audio_query
  and skips the folder walk, because an iOS app only sees its own sandbox.
  Library items without an asset URL (cloud or DRM) are skipped. iOS song
  paths are `ipod-library://` URLs, so `PlayerViewModel` plays them as URLs;
  everything else plays as a device file. These checks live in `core/`, never
  in views.

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
- The user-facing name is exactly "Z Play" (`appName` in `core/app/`); text
  people read uses that constant. Eyebrows show it in capitals with
  `appName.toUpperCase()`, since text styles can't change case. Identifiers
  keep their own spelling: the Dart package `musicplayer`, the Android
  applicationId and namespace, the iOS bundle identifier, and `ZPlayApp`.
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
| `preferences` | Settings, recently played, and the saved playback state: queue, index, position, speed, original order, shuffle, repeat |
| `recentlyPlayedBox` | Recently played from older versions; only read when `preferences` has no recent list yet |

The Hive adapters in `core/models/*.g.dart` use type ids 0 (`MusicFile`) and
1 (`Playlist`). `test/hive_adapters_test.dart` locks those ids, because
changing them would make existing installs' playlists unreadable.
