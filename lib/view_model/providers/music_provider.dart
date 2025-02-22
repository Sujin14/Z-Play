import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../model/model.dart';
import '../database/hive_storage.dart';
import '../permissions/file_scanner.dart';
import '../permissions/permissions_handler.dart';

class MusicProvider with ChangeNotifier {
  AudioPlayer audioPlayer = AudioPlayer();
  MusicFile? _currentMusicFile;
  bool _isPlaying = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;

  final Map<String, int> playCounts =
      {}; // Tracks how many times a song has been played

  List<MusicFile> _musicFiles = [];
  List<MusicFile> _favorites = [];

  List<MusicFile> get musicFiles => _musicFiles;
  List<MusicFile> get favorites => _favorites;
  List<Playlist> get playlists => HiveStorage.playlists;
  List<MusicFile> get recentlyPlayed => HiveStorage.recentlyPlayed;

  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  MusicFile? get currentMusicFile => _currentMusicFile;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  /// **Initializes Music Provider**
  MusicProvider() {
    _initialize();
  }

  /// **Loads Stored Data & Music Files**
  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    HiveStorage.loadFavorites();
    HiveStorage.loadPlaylists();
    HiveStorage.loadRecentlyPlayed();

    _musicFiles = await FileScanner.fetchAllMusicFiles();
    _favorites = HiveStorage.getFavorites();

    _isLoading = false;
    notifyListeners();

    // Listeners for Music Player Events
    audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    audioPlayer.onPlayerComplete.listen((event) {
      _isPlaying = false;
      _currentPosition = Duration.zero;
      notifyListeners();
    });
  }

  /// **Requests Storage Permission & Fetches Files**
  Future<void> requestStoragePermissionAndFetchFiles() async {
    _isLoading = true;
    notifyListeners();

    if (await PermissionsHandler.requestStoragePermission()) {
      _musicFiles = await FileScanner.fetchAllMusicFiles();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// **Plays a Song**
  Future<void> playMusic(MusicFile musicFile) async {
    await stopMusic(); // Ensure previous song stops before playing a new one
    _currentMusicFile = musicFile;
    await audioPlayer.play(DeviceFileSource(musicFile.path));
    _isPlaying = true;

    HiveStorage.addRecentlyPlayed(musicFile);
    incrementPlayCount(musicFile.path);
    notifyListeners();
  }

  /// **Increments Play Count of a Song**
  void incrementPlayCount(String songPath) {
    playCounts[songPath] = (playCounts[songPath] ?? 0) + 1;
    notifyListeners();
  }

  /// **Gets the Most Watched Songs (At Least 5 Plays)**
  List<MusicFile> getMostWatchedSongs(int limit) {
    List<MusicFile> validSongs =
        _musicFiles.where((song) => playCounts.containsKey(song.path)).toList();

    validSongs.sort(
        (a, b) => (playCounts[b.path] ?? 0).compareTo(playCounts[a.path] ?? 0));

    return validSongs.take(limit).toList();
  }

  /// **Pauses the Current Song**
  Future<void> pauseMusic() async {
    await audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// **Resumes the Paused Song**
  Future<void> resumeMusic() async {
    await audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  /// **Seeks to a Specific Position in the Song**
  Future<void> seekMusic(Duration position) async {
    await audioPlayer.seek(position);
  }

  /// **Stops the Current Song**
  Future<void> stopMusic() async {
    await audioPlayer.stop();
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  /// **Plays the Next Song in the List**
  Future<void> playNext() async {
    if (_currentMusicFile == null) return;

    int currentIndex = _musicFiles.indexOf(_currentMusicFile!);
    if (currentIndex < _musicFiles.length - 1) {
      await playMusic(_musicFiles[currentIndex + 1]);
    }
  }

  /// **Plays the Previous Song in the List**
  Future<void> playPrevious() async {
    if (_currentMusicFile == null) return;

    int currentIndex = _musicFiles.indexOf(_currentMusicFile!);
    if (currentIndex > 0) {
      await playMusic(_musicFiles[currentIndex - 1]);
    }
  }

  /// **Toggles Favorite Status of a Song**
  void toggleFavorite(MusicFile musicFile) {
    HiveStorage.toggleFavorite(musicFile);
    _favorites = HiveStorage.getFavorites(); // Reload favorites
    notifyListeners();
  }

  /// **Checks if a Song is Favorite**
  bool isFavorite(MusicFile musicFile) {
    return HiveStorage.isFavorite(musicFile);
  }

  /// **Creates a Playlist**
  Future<void> createPlaylist(String playlistName) async {
    await HiveStorage.createPlaylist(playlistName);
    notifyListeners();
  }

  /// **Adds a Song to a Playlist**
  Future<void> addSongToPlaylist(Playlist playlist, MusicFile song) async {
    await HiveStorage.addSongToPlaylist(playlist, song);
    notifyListeners();
  }

  /// **Removes a Song from a Playlist**
  Future<void> removeSongFromPlaylist(Playlist playlist, MusicFile song) async {
    await HiveStorage.removeSongFromPlaylist(playlist, song);
    notifyListeners();
  }

  /// **Deletes a Playlist**
  Future<void> deletePlaylist(Playlist playlist) async {
    await HiveStorage.deletePlaylist(playlist);
    notifyListeners();
  }

  /// **Disposes the Audio Player to Prevent Memory Leaks**
  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
