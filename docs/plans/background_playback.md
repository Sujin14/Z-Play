# Plan: background playback and lock-screen controls

Status: plan only. Nothing here is implemented yet. Package versions below
were resolved with `flutter pub add --dry-run` against this project on
1 November 2026 (no files changed) and the Android build files were read from
the pub cache. Nothing here was run on a device.

## 1. How playback works today

All playback lives in `lib/core/state/player_view_model.dart`
(`PlayerViewModel`, a `ChangeNotifier` provided app-wide):

| Part | Today |
|---|---|
| Engine | One `audioplayers` `AudioPlayer`, created in the constructor (injectable but never faked in tests). `ReleaseMode.stop`. |
| Queue | `PlaybackQueue` (`core/state/playback_queue.dart`): `_base` order, `_order` (shuffled or not), `index`. Pure Dart, covered by `playback_queue_test.dart`. The player itself only ever holds **one** source. |
| Current track | `_queue.current`. Every track change runs `_startCurrent()`: `stop()` → `play(source)` → `setPlaybackRate(speed)` → optional `seek(resumeAt)`. A `_playToken` drops stale starts. |
| Source | `DeviceFileSource(path)`, or `UrlSource(path)` for iOS `ipod-library://` URLs (`_sourceFor`). |
| Position | `onPositionChanged` → `ValueNotifier<Duration> position` (so only the seek bar and mini-player line repaint). Saved every 5 s. |
| Duration / state | `onDurationChanged`, `onPlayerStateChanged` → `duration`, `isPlaying`, `notifyListeners()`. |
| Completion | `onPlayerComplete` → `_handleComplete()` in Dart: "end of track" sleep → pause; repeat one → seek 0 + resume; otherwise `skipNext` and `_startCurrent`. **The next track is started from Dart.** |
| Sleep timer | Dart `Timer` (`startSleepTimer`) → `pause()`; "end of track" is the `stopAfterCurrent` flag read on completion. |
| Speed | `setPlaybackRate`, re-applied after every start; saved in the snapshot. |
| Errors | `_startCurrent` catches, sets `error = 'Cannot play <title>.'`, `isPlaying = false`. |
| History / counts | `_repository.recordPlay(song)` + `onPlayed()` (library `syncActivity`) inside `_startCurrent(countPlay: true)`. |
| Restore | `prepare()` → `restore()`: queue paths, index, position, speed from `PlaybackSnapshot` (Hive `preferences`). **Repeat mode and the shuffle flag are not saved.** |
| Audio session | `AudioContext`: Android `stayAwake: true`, media usage, `AndroidAudioFocus.gain`; iOS category `.playback`. |

Facts found in the plugins' sources that matter for the background:

- **iOS:** audioplayers_darwin 6.5.0 calls `controlAudioSession()` after
  state changes and **deactivates the `AVAudioSession` whenever no player is
  playing**. Because the app changes tracks with `stop()` then `play()` from
  Dart, there is a moment with the session inactive. In the background iOS
  can suspend the app in that gap, so the next track would not start. It also
  has no Now Playing info or remote commands.
- **Android:** audioplayers_android 5.3.0 requests audio focus but has no
  media session, no notification and no "becoming noisy" handling. The
  manifest has no `WAKE_LOCK`, so `stayAwake` can't hold its wake lock, and
  there is no foreground service.

What would have to change: the engine calls in `_startCurrent`, `toggle`,
`pause`, `seek`, `setSpeed`, `stop`, `_bindPlayer`, `_handleComplete` and
`_applyAudioContext`; how play counts are recorded on automatic track
changes; plus new platform setup. `PlaybackQueue`, the public API of
`PlayerViewModel`, every view and every feature view model can stay as they
are.

## 2. Options

Installed here: Android SDK platforms 31, 33–36 and a 37.0 preview (which
broke permission_handler 13.x); Flutter's default compileSdk/targetSdk 36,
minSdk 24; AGP 9.1.0, Kotlin 2.4.0, Gradle 9.3.1; Dart SDK `^3.6.0`.

| | A. audioplayers + audio_service | B1. just_audio + just_audio_background | **B2. just_audio + audio_service** |
|---|---|---|---|
| Packages (resolved) | audio_service 0.18.19, audio_session 0.2.4 (keep audioplayers 6.x) | just_audio 0.10.6, just_audio_background 0.0.1-beta.17 (pulls audio_service 0.18.19, audio_session 0.2.4, rxdart 0.28.0) | just_audio 0.10.6, audio_service 0.18.19, audio_session 0.2.4 |
| Android build | audio_service: compileSdk 35, minSdk 19, Java 17, androidx.media 1.7.0. audio_session: compileSdk 35, minSdk 24, **applies the Kotlin Gradle Plugin** (same warning on_audio_query already gives). All within what's installed. | as B2 | just_audio: compileSdk 35, minSdk 16, Java 17, media3/ExoPlayer 1.4.1; others as A. All within what's installed. |
| iOS `ipod-library://` | Works today (`UrlSource` → AVPlayer). | `AudioSource.uri(...)`: just_audio uses `AVURLAsset URLWithString:` for non-file URIs, which accepts `ipod-library://` URLs. Unverified on a device. | same as B1 |
| Track changes / gapless | Dart-driven `stop`/`play`: small gap, and on iOS the session goes inactive between tracks (background stall risk). No gapless. | Native playlist (`setAudioSources`): the platform moves to the next item itself, gapless, session stays active. | same as B1 |
| Sleep timer, speed | Unchanged. | Speed: `setSpeed`. Timer: Dart, unchanged. "End of track" needs care (the next item starts natively). | same as B1 |
| Notification / lock screen | audio_service handler wrapping our player. | Automatic from `MediaItem` tags; little control (one player, beta, fixed buttons/behavior). | Our own `AudioHandler`: full control of buttons, close, queue, state. |
| MVVM risk | Low code risk, **high runtime risk on iOS**. | Medium: the plugin owns the queue shown in the notification; harder to keep `PlaybackQueue` as the single source of truth. Beta package. | Medium, contained in `core/`. |
| `PlayerViewModel` rewrite | ~20% (bridge to a handler). | ~40–50% | ~40% (engine calls and streams; public API unchanged) |
| Test impact | New handler tests. | Harder to fake (plugin-managed). | New `FakePlaybackEngine` and handler tests; `PlayerViewModel` becomes testable for the first time. |

**C. Others considered and rejected.** `media_kit` (libmpv): large native
libraries, still needs audio_service for a media session, and no
`ipod-library://` support. `assets_audio_player`: unmaintained. Writing
native services by hand: not needed, because the packages above cover
everything.

**Recommendation: B2 (just_audio 0.10.6 + audio_service 0.18.19 +
audio_session 0.2.4).** It is the only option where the platform itself
advances tracks, so playback survives the background on iOS. audio_service
gives full control of the notification and lock screen while `PlaybackQueue`
stays the single source of truth.

## 3. Android

**Manifest** (`android/app/src/main/AndroidManifest.xml`):

- Permissions:
  - `WAKE_LOCK`;
  - `FOREGROUND_SERVICE`;
  - `FOREGROUND_SERVICE_MEDIA_PLAYBACK` (Android 14+);
  - All three are install-time permissions with no dialog.
    `POST_NOTIFICATIONS` is **not** requested (decision 4).
- `<service android:name="com.ryanheise.audioservice.AudioService"
  android:foregroundServiceType="mediaPlayback" android:exported="true">`
  with the `android.media.browse.MediaBrowserService` intent filter.
- `<receiver android:name="com.ryanheise.audioservice.MediaButtonReceiver"
  android:exported="true">` with `android.intent.action.MEDIA_BUTTON`.
- `MainActivity` (`com.sujin.musicplayer`) changes from `FlutterActivity` to
  `AudioServiceActivity`, so the Flutter engine outlives the activity while
  the service plays.

**Notification**:

- **Channel:** id `zplay.playback`, name "Playback", low importance (no sound).
  Set via `AudioServiceConfig(androidNotificationChannelId, androidNotificationChannelName)`.
- **Content:** title = song title, text = artist. No artwork (decision 1).
  Small icon: a monochrome notification icon, to be added to
  `res/drawable`, because the launcher image is a photo.
- **Actions.** Android allows at most 5 actions in the expanded
  notification and 3 in the compact one, so there is no close button
  (decision 2):
  - Compact (3): previous, play/pause, next.
  - Expanded (5): rewind 10 s, previous, play/pause, next, forward 10 s.
  - With audio_service: `controls: [rewind, skipToPrevious, play or pause,
    skipToNext, fastForward]`, `androidCompactActionIndices: [1, 2, 3]`,
    `AudioServiceConfig(rewindInterval: 10 s, fastForwardInterval: 10 s)`.
- **When paused:** `androidStopForegroundOnPause: true`. The service leaves the
  foreground and the notification becomes swipe-away. **Swiping it away
  stops the service.** The queue is already saved and is restored on the next
  launch, and Android may later stop the process.
- **When the sleep timer ends:** pause and keep the notification (decision 3).

**Media buttons**:

- Headset, Bluetooth and the Android 11+ media controls all go through the
  media session that audio_service creates.
- `MediaButtonReceiver` handles them when the app isn't in the foreground.

**Audio focus and "becoming noisy"**:

- audio_session's `AudioSessionConfiguration.music()` asks for gain focus.
- just_audio's interruption handling (on by default):
  - permanent loss → pause;
  - transient loss → pause, then resume when focus returns;
  - "can duck" → lower the volume.
- Unplugging headphones fires audio_session's `becomingNoisyEventStream` →
  pause.
- Verify each on a device.

**Android 13+ with notifications denied**:

- Android exempts media-session notifications from the `POST_NOTIFICATIONS`
  requirement, and the foreground service runs whether the notification is
  shown or not.
- So playback continues either way. If no media controls appear, the app
  still works from inside, and the user can turn notifications on in system
  settings.
- Decided: **don't ask for `POST_NOTIFICATIONS`** and rely on the exemption
  (decision 4), so there's no new prompt and no new permission in the
  Privacy policy. Verify on an Android 13 and an Android 14 device.

## 4. iOS

- **Info.plist:** `UIBackgroundModes` = `audio`.
- **Audio session:** audio_session `AudioSessionConfiguration.music()`
  (category `.playback`, mode default), activated on play. just_audio keeps it
  active across playlist items.
- **Now Playing:** audio_service's iOS side fills `MPNowPlayingInfoCenter`
  from our `MediaItem`: title, artist, album, duration, elapsed time and rate
  (rate follows the speed setting).
- **Remote commands** (`MPRemoteCommandCenter`): enabled are play, pause,
  toggle play/pause, `nextTrackCommand`, `previousTrackCommand` and
  `changePlaybackPositionCommand` (the lock-screen seek bar). These cover the
  lock screen, Control Center, AirPods and CarPlay's basic controls; CarPlay
  browsing is out of scope.
- **10-second skip on iOS: not enabled.** Apple's `MPRemoteCommandCenter`
  reference lists `skipForwardCommand` / `skipBackwardCommand` (both
  `MPSkipIntervalCommand`) and `nextTrackCommand` / `previousTrackCommand`
  but doesn't say what the lock screen shows when both pairs are enabled.
  Developer reports (Apple Developer Forums) agree that the lock screen shows
  **one pair only**, and that the skip-interval buttons take the place of
  next/previous. Because iOS doesn't show both pairs, we keep next/previous
  and leave the skip commands off. The 10-second skip is Android-only (in
  the notification) and in-app (see the note under section 8). Confirm on a
  device in step 5.
- **Interruptions** (calls, Siri, alarms): audio_session
  `interruptionEventStream`. Playback pauses when the interruption begins
  and **resumes automatically only if it was playing before** and the system
  says it may (decision 5). Android transient focus loss follows the same
  rule.
- **`ipod-library://` in the background:** these are local MediaPlayer
  assets read by AVFoundation, so they play in the background like files.
  Cloud-only and DRM items are already skipped by the scanner. Expected to
  work, unverified.

## 5. Where the code lives

Everything new is in `core/`; no view or feature changes.

```
lib/core/services/
  playback_engine.dart        PlaybackEngine (interface): setQueue(songs, index, position),
                              play, pause, seek, seekBy(Duration), skipTo(index), setSpeed,
                              setRepeat(RepeatMode), insert/remove/move, stop; streams:
                              playing, position, duration, currentIndex, completed, errors
  just_audio_engine.dart      JustAudioEngine implements PlaybackEngine (native playlist,
                              LoopMode from RepeatMode, ipod-library → AudioSource.uri)
  media_session_handler.dart  ZPlayAudioHandler extends BaseAudioHandler with SeekHandler:
                              system buttons → PlaybackControls; publishes MediaItem and
                              PlaybackState from PlayerViewModel's state
  playback_controls.dart      PlaybackControls (interface): play, pause, next, previous,
                              seek, seekBy(Duration), stop. Implemented by PlayerViewModel, so
                              the handler doesn't depend on the view model's class. The
                              handler's rewind / fastForward call seekBy(-10 s) / seekBy(+10 s).
```

- `main.dart`: `await AudioService.init(builder: () => ZPlayAudioHandler(...),
  config: AudioServiceConfig(...))` before `runApp`. `PlayerViewModel` gets a
  `PlaybackEngine` and a `MediaSession` publisher (a thin interface over the
  handler) through its constructor, like the repository today.
- `PlayerViewModel` keeps its public API and stays the single owner of
  state. `PlaybackQueue` stays the single source of truth for order; the
  engine just mirrors it.
- Tests use `FakePlaybackEngine` and a fake session publisher, so
  `PlayerViewModel` can be unit-tested for the first time.

**Previous** keeps today's rule (`PlayerViewModel.previous()`):

- If the current song has played **more than 3 seconds**
  (`_restartThreshold = Duration(seconds: 3)`; strictly greater than), it
  restarts the current song.
- Otherwise it goes to the previous song.
- At the first song, it restarts.

The notification, lock screen and headset "previous" all call this same
method.

**Skip 10 s** (`PlayerViewModel.seekBy(Duration)`; the engine gets the same
method):

- Rewind clamps at 0.
- Forward clamps at the song's duration, so the song completes normally and
  the queue advances by the usual completion path, honoring repeat and the
  "end of track" sleep.

Tests to write for it (with `FakePlaybackEngine`):

- rewinding near the start clamps at 0;
- forwarding near the end clamps at the duration;
- forwarding at the end completes the song and advances to the next one;
- with repeat one it replays; with "end of track" sleep it pauses;
- the notification/handler rewind and forward call `seekBy(∓10 s)`.

## 6. Keeping existing features working

| Feature | With B2 |
|---|---|
| Queue edits (play next, add, remove, reorder) | Update `PlaybackQueue` first, then mirror with `insertAudioSource` / `removeAudioSourceAt` / `moveAudioSource`, so playback isn't restarted. Removing the current item still skips to the next one, as today. |
| Shuffle | Keep our `PlaybackQueue` shuffle (just_audio's own shuffle stays off). Toggling it rebuilds the native list around the current item without interrupting it. |
| Repeat | `RepeatMode.off/all/one` → `LoopMode.off/all/one`. |
| Sleep timer (minutes) | Unchanged Dart `Timer` → `pause()`. It runs in the background because the foreground service (Android) or the active audio session (iOS) keeps the app alive. When it ends, playback pauses and the notification stays (decision 3). |
| Sleep "end of track" | Arming it trims the native playlist to the current item (the app queue stays whole), so the platform stops at its end; the full list is restored on the next play. Otherwise the next track would already have started before Dart sees the change. |
| Speed | `setSpeed`; also reported to Now Playing and the media session. |
| Favorites | Unchanged (Dart only). |
| Mini player and Now Playing | Unchanged: they still listen to `PlayerViewModel` (`isPlaying`, `current`, `position`). |
| History and play counts | Today they're recorded when Dart starts a track. With native advancement, record on `currentIndexStream` changes caused by playback (not by our own `setQueue`), plus explicit starts. |
| Errors | The engine's error stream → `error = 'Cannot play <title>.'`, then skip to the next item (as players usually do) or stop when none is left. |
| Returning after a long time in the background | Save on pause, on track change and every 5 s (as today). If the OS killed the process, the splash restores the snapshot as it does now. If the process lived, state is already current. **Repeat mode and shuffle are saved and restored too** (decision 6): the snapshot gains both, and shuffle restores the saved order plus the original order. |

## 7. Store and legal impact

**Privacy policy:**

- §3 Permissions: stays "audio permission only" (we don't ask for
  `POST_NOTIFICATIONS`, decision 4), plus one bullet, because the store
  listings will show the new technical permissions:
  > - Background playback (Android): lets music keep playing with the
  >   screen off and shows playback controls in the notification area. It
  >   gives the app no access to your data. On iPhone this is the standard
  >   background audio mode.
- §1 and §4 are unchanged: nothing is collected or sent. The lock screen and
  notification show the song title and artist on the device only.

**Terms:** §4 Permissions gets one sentence:
> On Android the app also uses a background playback service to keep music
> playing when the screen is off.

**Help:**

- New FAQ, "Does music keep playing when I lock my phone?":
  > Yes. Use the controls in the notification or on the lock screen. To
  > stop, pause and swipe the notification away.
- FAQ 5: add "The sleep timer keeps running while the screen is off."

The notification layout (no close button, 10-second skips) changes no
permission and no other Privacy, Terms or Help text. The only wording that
followed from it is the FAQ answer above, which no longer mentions a close
button.

**Google Play, foreground service declaration** (App content → Foreground
service permissions):

- **Type:** Media playback.
- **Description:**
  > Z Play plays music stored on the user's device. While music is playing,
  > a media playback foreground service keeps playback going when the app is
  > in the background or the screen is off, and shows playback controls.
- **Video:** a link to a short video showing playback continuing with the
  screen off and the notification controls. Google normally asks for one.

**Data safety:** unchanged. No data collected, no data shared, no data
encrypted in transit (nothing is sent), and the user can request deletion by
uninstalling.

**App Store review notes:**
> Z Play uses the audio background mode only to keep playing the user's own
> music library when the app is in the background or the screen is locked,
> with lock-screen and Control Center controls. No account is needed. To
> test: play any song, lock the device, use the lock-screen controls.

## 8. Steps (each one prompt-sized, in order)

| # | Step | Verify on a device afterwards | Risk / effort |
|---|---|---|---|
| 1 ✅ done | Extract `PlaybackEngine`; move today's audioplayers code into `AudioplayersEngine`; `PlayerViewModel` uses the interface. Add `FakePlaybackEngine` and the first `PlayerViewModel` tests (completion, end of track, repeat one, counts). No behavior change. | Everything plays exactly as before. | Low / M |
| 2 ✅ done | Add just_audio; `JustAudioEngine` with a native playlist mirroring `PlaybackQueue`, loop mode, speed, `seekBy` with clamping, queue edits, the end-of-track trim, play counts on index changes. Switch `PlayerViewModel` to it (adding `seekBy`); keep `AudioplayersEngine` until verified. Tests: the `seekBy` cases listed in section 5. | Android and iOS: play, next/previous (3-second restart rule), gapless, repeat all/one, shuffle on/off mid-song, queue edits during playback, speed, both sleep modes, iOS `ipod-library` songs. | Medium-high / L |
| 3 ✅ done (audioplayers and `AudioplayersEngine` removed; audio session set to music; interruptions and unplugging use just_audio's defaults. Left: confirm the focus, call and unplug behavior on devices) | Remove audioplayers and `AudioplayersEngine`; configure audio_session (music); interruption and becoming-noisy handling. | Headphones unplugged pause playback; a call pauses and then resumes; another app taking audio pauses ours. | Medium / S |
| 4 | Android background: audio_service (`ZPlayAudioHandler` with rewind/fastForward → `seekBy(∓10 s)`, `PlaybackControls`), `AudioServiceActivity`, manifest service, receiver and permissions, notification channel and icon, the compact (3) and expanded (5) actions, `AudioService.init` in `main.dart`. Tests: handler rewind/forward call `seekBy`. | Screen off for 10+ min keeps playing; compact and expanded notification buttons, including ±10 s; headset and Bluetooth buttons; swipe the app away; swipe away the paused notification stops the service; the sleep timer with the screen off keeps the notification; Android 13+ with notifications denied. | Medium-high / L |
| 5 | iOS background: `UIBackgroundModes audio`, Now Playing and remote commands (play, pause, toggle, next, previous, change position; no skip-interval commands) through the same handler. | Lock screen and Control Center show next/previous and the seek bar; AirPods double-tap; a call and Siri interrupting (resumes only if it was playing); `ipod-library` songs advancing while locked. Needs a Mac and an iPhone. | Medium / M |
| 6 | State restore hardening: save on pause and track change; save and restore repeat and shuffle; restore after the process is killed. | Pause, background for an hour, force-kill, reopen: same song, position, repeat and shuffle. | Low / S |
| 7 | Privacy, Terms and Help text plus tests (the FAQ counts change). | Read the pages on both platforms. | Low / S |
| 8 | Store prep: Play foreground service declaration and video, Data safety review, App Store review notes. | Internal testing track and TestFlight builds. | Low / S |

Note: an in-app 10-second control on Now Playing is a separate small UI
step after the engine work (steps 1 to 3), pending a decision on where it
goes on the screen. It calls the same `PlayerViewModel.seekBy`.

## 9. Decisions

1. **Artwork:** none in the notification or on the lock screen.
2. **Close button:** none in the notification. Android allows at most 5
   expanded and 3 compact actions, and the 10-second skips take the spare
   slots. Swiping away the paused notification stops the service; the queue
   stays saved and is restored on the next launch.
3. **Sleep timer ends:** pause and keep the notification.
4. **Android 13+:** rely on the media-notification exemption; don't request
   `POST_NOTIFICATIONS`. Privacy §3 stays "audio permission only" plus the
   Background playback bullet.
5. **Interruptions** (a call, Siri): resume automatically only if it was
   playing before.
6. **Restore:** repeat mode and shuffle are saved and restored across
   restarts.
7. **Extra controls:** add 10-second rewind and forward (Android
   notification and in-app; not on the iOS lock screen, see section 4).

## 10. Not verified (needs a device or a Mac)

- `ipod-library://` playback through just_audio's `AVURLAsset`, and in the
  background.
- That just_audio's default interruption and becoming-noisy handling behaves
  as described.
- The Android 13+ media-notification exemption with notifications denied.
- The Android 14 foreground-service-type checks.
- Whether audio_session's Kotlin Gradle Plugin use builds cleanly here (the
  versions were resolved and their Gradle files read, but not built).
- Whether Google Play requires the video for the media playback declaration
  for this app.
- Which pair the iOS lock screen shows when skip-interval and next/previous
  commands are both enabled (Apple's reference doesn't say; developer reports
  say skip-interval wins). Moot while we leave skip-interval off, but check
  that next/previous appear.
- That seeking to exactly the duration makes just_audio complete the song
  and advance on both platforms.
