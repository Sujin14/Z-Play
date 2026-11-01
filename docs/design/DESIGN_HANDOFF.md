# Z Play redesign: handoff for the build

Visual reference: the exported PDF in this folder (one page per artboard). Code layout: see docs/ARCHITECTURE.md. Build to match it. This file gives exact values the PDF can't.
Keep every feature in the original UI report. This is a visual and layout redesign, not a feature change.

## 1. Rules
- One accent: neon green. Every "on" state (repeat, shuffle, sleep timer, current song, selected tab, switches, chips) uses it.
- Coral is only for the favorite heart and destructive actions.
- Every screen has the gradient background (tokens below). Content sits on translucent glass surfaces.
- Dark is the default. Light mode uses the same layout with the light tokens. The Now Playing gradient follows the theme.
- Touch targets are at least 44x44.
- Bottom nav is a floating pill with labels. The mini player sits just above it.

## 2. Packages
`google_fonts` (Sora for headings, Plus Jakarta Sans for text), `lottie`. Remove `curved_navigation_bar`.

## 3. Tokens (lib/core/theme/app_colors.dart)

```dart
import 'package:flutter/material.dart';

abstract final class AppColors {
  // Brand
  static const neon = Color(0xFF39FF5A);
  static const aqua = Color(0xFF19D3A0);
  static const lime = Color(0xFFC9F31D);
  static const onAccent = Color(0xFF04200E); // text/icons on green

  // Dark
  static const dBase = Color(0xFF031109);
  static const dMid = Color(0xFF072A1B);
  static const dEnd = Color(0xFF0A3D38);
  static const dText = Color(0xFFEAF7EE);
  static const dText2 = Color(0xFFA0BEAC);
  static const dCard = Color(0x0FFFFFFF);   // white 6%
  static const dLine = Color(0x1AFFFFFF);   // white 10%
  static const dChip = Color(0x2639FF5A);   // neon 15%
  static const dGlass = Color(0xCC082015);  // nav, mini player
  static const dSheet = Color(0xFF0A261B);
  static const dHeart = Color(0xFFFF7A93);

  // Light
  static const lBase = Color(0xFFF6FFF8);
  static const lMid = Color(0xFFD9F7E3);
  static const lEnd = Color(0xFFC7EFEA);
  static const lText = Color(0xFF0A2415);
  static const lText2 = Color(0xFF46624F);
  static const lAccentText = Color(0xFF076322); // green used as TEXT on light (5.3:1 on lChip)
  static const lCard = Color(0x9EFFFFFF);
  static const lLine = Color(0x1F084623);
  static const lChip = Color(0x2E16C24A);
  static const lGlass = Color(0xDBFFFFFF);
  static const lSheet = Color(0xFFF4FFF8);
  static const lHeart = Color(0xFFC72A4B); // also the light Delete button fill, white text (5.4:1)

  // Gradients
  static const darkBg = LinearGradient(
    begin: Alignment(-0.3, -1), end: Alignment(0.3, 1),
    colors: [dBase, dMid, dEnd], stops: [0, .5, 1]);
  static const lightBg = LinearGradient(
    begin: Alignment(-0.3, -1), end: Alignment(0.3, 1),
    colors: [lBase, lMid, lEnd], stops: [0, .52, 1]);
  static const action = LinearGradient(
    begin: Alignment.topLeft, end: Alignment.bottomRight,
    colors: [neon, aqua]); // primary buttons, selected chips, play button, seek fill

  // Cover fallback tiles (no embedded art), picked from a stable hash of the title.
  static const covers = <List<Color>>[
    [Color(0xFF39FF5A), Color(0xFF0B6B3A)],
    [Color(0xFF19D3A0), Color(0xFF0A3A66)],
    [Color(0xFFC9F31D), Color(0xFF1E7A3A)],
    [Color(0xFF2BD9FF), Color(0xFF0B4A5A)],
    [Color(0xFF7CFFB2), Color(0xFF1A5C4A)],
    [Color(0xFFA8FF3E), Color(0xFF0D5C2B)],
    [Color(0xFF0FD9C0), Color(0xFF1B4D3E)],
    [Color(0xFF5DFF9A), Color(0xFF126B55)],
  ];
}
```

Cover tile: 135deg gradient plus a soft white radial highlight at the top-left (30% opacity). Use the same widget everywhere art is shown.

## 4. Theme (lib/core/theme/app_theme.dart, with app_tokens.dart, app_radii.dart, app_spacing.dart and app_sizes.dart)
Build `ThemeData(useMaterial3: true)` for dark and light:
- `scaffoldBackgroundColor: Colors.transparent`. Wrap every screen body in a `GradientScaffold` (lib/core/widgets/gradient_scaffold.dart) that paints `AppColors.darkBg` or `lightBg` behind it, plus two soft radial glows (neon 20% top-right, aqua 16% left-middle).
- Primary: `neon` (dark), `Color(0xFF16C24A)` (light). `onPrimary: onAccent`.
- App bars: transparent, no elevation, left-aligned, no tint.
- Switch: track = `action` gradient when on (use a custom widget), thumb white 24px.
- Slider: 6px track, active = `action`, thumb 16px white with a 4px neon 40% ring.
- Text: headings `GoogleFonts.sora` w700/w800; everything else `GoogleFonts.plusJakartaSans`.

| Style | Font | Size / weight |
|---|---|---|
| Screen title | Sora | 30 / 800, letter-spacing -0.02em |
| Sheet title, empty-state title | Sora | 20-22 / 700 |
| Player title | Sora | 24 / 700 |
| Row title | Jakarta | 15 / 600 |
| Subtitle | Jakarta | 12.5-13 / 500, text2 |
| Eyebrow label | Jakarta | 11 / 700, caps, +0.16em, accent text |

Radii: cover thumb 14, cards 24, sheets 30 (top), nav pill 34, mini player 22, buttons and chips fully round, album cover 22, Now Playing cover 36.
Spacing: screen side padding 20, list side padding 10, gaps in multiples of 4.

## 5. Shared widgets to create first
1. `GradientScaffold` (core/widgets/gradient_scaffold.dart)
2. `CoverArt` (core/widgets/cover_art.dart; embedded art or fallback tile, size and radius params), plus `CoverCollage`, `AlbumCover` and `ArtistAvatar`
3. `SongTile` (core/widgets/song_tile.dart; cover, title, "artist · album", duration, one ⋮ button; heart appears as a small icon beside the title if favorite; playing row = chip background plus equalizer bars over the cover)
4. `MiniPlayer` (features/shell/widgets/mini_player.dart; cover, title/artist, play/pause gradient circle, close, 3px progress line on the bottom edge)
5. `FloatingNavBar` (features/shell/widgets/floating_nav_bar.dart; floating pill, 4 labelled items, selected = chip background plus accent color)
6. `PrimaryButton`, `GhostButton`, `PillChip` (core/widgets), `SegmentedPill` (features/history/widgets)
7. `AppSheet` with `showAppSheet` (top radius 30, handle bar, scrim), `EmptyState` (rings + icon + title + one line + optional button), `SnackPill` with `showSnackPill` (all core/widgets)
8. `SongMenuSheet` with `showSongMenu` (core/widgets/song_menu_sheet.dart), a bottom sheet (Play next, Add to queue, Add to playlist, Add/Remove favorite, Remove from playlist only in playlist detail)

## 6. Screens (see PDF page for each)
- Splash: ring "Z" mark, wordmark, tagline, thin progress bar plus "Scanning your library…". No black-box JPEG: use a transparent PNG/SVG or the CSS-style ring in code.
- Library: eyebrow + title, rescan icon, search field always visible, chips Songs/Folders/Albums/Artists, row with count and a visible sort button (opens the sort sheet). Songs = `SongTile` list. Folders = glass rows with folder icon and hide button. Albums = 2-col cover grid. Artists = 3-col circular avatars (initial on fallback tile).
- Collection detail (album/artist/folder): back button, 176px cover, title, "artist · N tracks · duration", Play all (primary) + Shuffle (ghost), track list with numbers; current track shows equalizer.
- Favorites: title with heart badge, glass header card with count/duration and Play all + Shuffle, then list.
- Playlists: 2-col grid, cover = 2x2 collage of the first 4 song covers, ⋮ button on each card (rename, delete). Edit and delete are NOT always visible. Last tile = dashed "New playlist". Header has a "New" button.
- Playlist detail: collage cover, Edit button in the top bar, Play all + Shuffle, list with Remove in each song menu.
- History: segmented Recently played / Most played. Most played shows a rank number and a "42×" pill.
- Now Playing: see section 7.
- Queue: back, "Save as playlist" button, "Now playing" highlighted card, "Up next" list with drag handle, cover, title, remove X. Reorder by drag.
- Settings: grouped glass cards: Appearance, Library (two switches, Rescan), Hidden folders (with count and show buttons), Listening history, About. Footer: wordmark + version.
- Info page: logo ring, title, one glass card per section.
- Sheets: song menu, add to playlist (collage thumbs, check on playlists that already have the song), playlist editor (name, search, selected count, checklist, Save), sleep timer (countdown ring when active, chips 15/30/45/60/End of track, Cancel), sort, delete confirmation.
- States: empty, error and 404 use `EmptyState`. Snackbars are floating glass pills with a leading icon.

## 7. Now Playing and the Lottie file
Layout (no scrolling on a normal phone), top to bottom:
1. Top bar: down-chevron (back), center "NOW PLAYING" + "From <album>".
2. Cover area 300x300, radius 36, with a green glow shadow.
3. Title (Sora 24, ellipsis or marquee) + "artist · album", favorite heart on the right (coral when on).
4. Seek bar with elapsed and total time.
5. Controls: shuffle · previous · big play/pause (78px, `action` gradient) · next · repeat. Active shuffle/repeat = accent color with a small dot underneath.
6. Action bar: Playlist · Sleep timer (shows the live countdown when set) · Speed (shows "1x"; tap opens a speed sheet 0.75/1/1.25/1.5/2) · Queue.
7. "Up next" pill showing the next song.

Lottie: keep using `assets/json/music_player.json`.
- Cover area logic: if the song has embedded artwork, show it. If not, show the fallback tile and put the Lottie on top of it, centered, about 70% of the cover size.
- Animate only while playing: `Lottie.asset('assets/json/music_player.json', controller: _ctrl)`; call `_ctrl.repeat()` on play and `_ctrl.stop()` on pause. If the animation has its own solid background, set the cover tile behind it and test `fit: BoxFit.contain`.
- If the Lottie's colors clash with the green palette, recolor with `ValueDelegate.color` for the main layer keypaths, or edit the colors in LottieFiles.
- Use the same Lottie on the splash? No: the splash uses the ring mark.

## 8. Motion
- Page transitions: fade + 8px upward slide, 250ms.
- Play button press: scale to 0.94.
- Equalizer bars: 3 bars looping while the song is playing.
- Sheets: standard bottom-sheet slide.

## 9. Do not change
All behavior, data models, storage, permissions and routes from the current app. Tapping a song still plays it and opens Now Playing.

## 10. Build order (one step per commit)
1. Packages, colors, theme, `GradientScaffold`, shared widgets
2. Main shell: nav bar and mini player
3. Library (all four tabs) and song tile
4. Collection detail, Favorites, Playlists, Playlist detail
5. Now Playing + Lottie, Queue
6. Sheets and dialogs
7. Settings, History, Info, Splash, empty/error states
8. Light-mode pass on every screen
