import 'package:flutter/foundation.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../domain/entities/music_file_entity.dart';
import '../../domain/repositories/music_repository.dart';
import '../../domain/usecases/fetch_music_files.dart';
import '../../domain/usecases/toggle_favorite.dart';
import '../../domain/usecases/add_recently_played.dart';
import '../../domain/usecases/get_most_played.dart';
import '../../../../core/di/dependency_injection.dart';

enum RepeatMode { off, all, one }

class MusicViewModel with ChangeNotifier {
  final FetchMusicFiles fetchMusicFiles;
  final ToggleFavorite toggleFavorite;
  final AddRecentlyPlayed addRecentlyPlayed;
  final GetMostPlayed getMostPlayed;
  AudioPlayer audioPlayer = AudioPlayer();
  MusicFileEntity? _currentMusicFile;
  List<MusicFileEntity> _currentPlaylist = [];
  int _currentIndex = 0;
  bool _isPlaying = false;
  bool _isShuffling = false;
  RepeatMode _repeatMode = RepeatMode.off;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  bool _isLoading = false;
  List<MusicFileEntity> _musicFiles = [];
  List<MusicFileEntity> _favorites = [];
  List<MusicFileEntity> _recentlyPlayed = [];
  List<MusicFileEntity> _mostPlayedSongs = [];

  MusicViewModel({
    required this.fetchMusicFiles,
    required this.toggleFavorite,
    required this.addRecentlyPlayed,
    required this.getMostPlayed,
  }) {
    _initialize();
  }

  bool get isLoading => _isLoading;
  bool get isPlaying => _isPlaying;
  bool get isShuffling => _isShuffling;
  RepeatMode get repeatMode => _repeatMode;
  MusicFileEntity? get currentMusicFile => _currentMusicFile;
  List<MusicFileEntity> get currentPlaylist => _currentPlaylist;
  int get currentIndex => _currentIndex;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;
  List<MusicFileEntity> get musicFiles => _musicFiles;
  List<MusicFileEntity> get favorites => _favorites;
  List<MusicFileEntity> get recentlyPlayed => _recentlyPlayed;
  List<MusicFileEntity> get mostPlayedSongs => _mostPlayedSongs;

  Future<void> _initialize() async {
    _isLoading = true;
    notifyListeners();

    _musicFiles = await fetchMusicFiles();
    _favorites = await getIt<MusicRepository>().getFavorites();
    _recentlyPlayed = await getIt<MusicRepository>().getRecentlyPlayed();
    _mostPlayedSongs = await getMostPlayed(10);

    _isLoading = false;
    notifyListeners();

    audioPlayer.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });

    audioPlayer.onPositionChanged.listen((position) {
      _currentPosition = position;
      notifyListeners();
    });

    audioPlayer.onPlayerComplete.listen((event) {
      if (_repeatMode == RepeatMode.one) {
        playMusic(_currentMusicFile!, _currentPlaylist, _currentIndex);
      } else if (_repeatMode == RepeatMode.all && _currentPlaylist.isNotEmpty) {
        playNext();
      } else {
        _isPlaying = false;
        _currentPosition = Duration.zero;
        notifyListeners();
      }
    });
  }

  Future<void> requestStoragePermissionAndFetchFiles() async {
    _isLoading = true;
    notifyListeners();
    _musicFiles = await fetchMusicFiles();
    _favorites = await getIt<MusicRepository>().getFavorites();
    _recentlyPlayed = await getIt<MusicRepository>().getRecentlyPlayed();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> playMusic(MusicFileEntity musicFile,
      List<MusicFileEntity> playlist, int index) async {
    await audioPlayer.stop();
    _currentMusicFile = musicFile;
    _currentPlaylist = playlist;
    _currentIndex = index;
    await audioPlayer.play(DeviceFileSource(musicFile.path));
    _isPlaying = true;
    await addRecentlyPlayed(musicFile);
    await getIt<MusicRepository>().incrementPlayCount(musicFile.path);
    _recentlyPlayed = await getIt<MusicRepository>().getRecentlyPlayed();
    _mostPlayedSongs = await getMostPlayed(10);
    _setReleaseMode();
    notifyListeners();
  }

  Future<void> pauseMusic() async {
    await audioPlayer.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resumeMusic() async {
    await audioPlayer.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> stopAndClearMusic() async {
    await audioPlayer.stop();
    _isPlaying = false;
    _currentMusicFile = null;
    _currentPlaylist = [];
    _currentIndex = 0;
    _currentPosition = Duration.zero;
    _totalDuration = Duration.zero;
    notifyListeners();
  }

  Future<void> seekMusic(Duration position) async {
    await audioPlayer.seek(position);
    notifyListeners();
  }

  Future<void> playNext() async {
    if (_currentPlaylist.isEmpty) return;
    if (_currentIndex < _currentPlaylist.length - 1) {
      _currentIndex++;
      await playMusic(
          _currentPlaylist[_currentIndex], _currentPlaylist, _currentIndex);
    } else if (_repeatMode == RepeatMode.all) {
      _currentIndex = 0;
      await playMusic(
          _currentPlaylist[_currentIndex], _currentPlaylist, _currentIndex);
    }
  }

  Future<void> playPrevious() async {
    if (_currentPlaylist.isEmpty) return;
    if (_currentIndex > 0) {
      _currentIndex--;
      await playMusic(
          _currentPlaylist[_currentIndex], _currentPlaylist, _currentIndex);
    }
  }

  void toggleShuffle() {
    _isShuffling = !_isShuffling;
    if (_isShuffling) {
      _currentPlaylist.shuffle();
      if (_currentMusicFile != null) {
        _currentIndex = _currentPlaylist
            .indexWhere((song) => song.path == _currentMusicFile!.path);
      }
    }
    notifyListeners();
  }

  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    _setReleaseMode();
    notifyListeners();
  }

  void _setReleaseMode() {
    if (_repeatMode == RepeatMode.one) {
      audioPlayer.setReleaseMode(ReleaseMode.loop);
    } else {
      audioPlayer.setReleaseMode(ReleaseMode.stop);
    }
  }

  Future<void> toggleFavoriteSong(MusicFileEntity musicFile) async {
    await toggleFavorite(musicFile);
    _favorites = await getIt<MusicRepository>().getFavorites();
    notifyListeners();
  }

  bool isFavorite(MusicFileEntity musicFile) {
    return _favorites.any((fav) => fav.path == musicFile.path);
  }

  Future<List<MusicFileEntity>> getMostPlayedSongs(int limit) async {
    final songs = await getMostPlayed(limit);
    return songs;
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }
}
