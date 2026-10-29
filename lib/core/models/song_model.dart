class Song {
  const Song({
    required this.path,
    required this.title,
    this.artist = 'Unknown artist',
    this.album = 'Unknown album',
    this.genre = '',
    this.durationMs = 0,
    this.dateAddedMs = 0,
    this.isSystemSound = false,
  });

  final String path;
  final String title;
  final String artist;
  final String album;
  final String genre;
  final int durationMs;
  final int dateAddedMs;
  final bool isSystemSound;

  Duration get duration => Duration(milliseconds: durationMs);

  String get folderPath {
    final normalized = path.replaceAll('\\', '/');
    final separator = normalized.lastIndexOf('/');
    if (separator <= 0) return normalized;
    return normalized.substring(0, separator);
  }

  String get folderName {
    final folder = folderPath;
    final separator = folder.lastIndexOf('/');
    if (separator < 0 || separator == folder.length - 1) return folder;
    return folder.substring(separator + 1);
  }

  String get subtitle {
    if (album == 'Unknown album') return artist;
    return '$artist · $album';
  }

  Song copyWith({
    String? title,
    String? artist,
    String? album,
    String? genre,
    int? durationMs,
    int? dateAddedMs,
    bool? isSystemSound,
  }) {
    return Song(
      path: path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      durationMs: durationMs ?? this.durationMs,
      dateAddedMs: dateAddedMs ?? this.dateAddedMs,
      isSystemSound: isSystemSound ?? this.isSystemSound,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'title': title,
      'artist': artist,
      'album': album,
      'genre': genre,
      'durationMs': durationMs,
      'dateAddedMs': dateAddedMs,
      'system': isSystemSound,
    };
  }

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      path: json['path'] as String? ?? '',
      title: json['title'] as String? ?? 'Unknown',
      artist: json['artist'] as String? ?? 'Unknown artist',
      album: json['album'] as String? ?? 'Unknown album',
      genre: json['genre'] as String? ?? '',
      durationMs: json['durationMs'] as int? ?? 0,
      dateAddedMs: json['dateAddedMs'] as int? ?? 0,
      isSystemSound: json['system'] as bool? ?? false,
    );
  }

  @override
  bool operator ==(Object other) => other is Song && other.path == path;

  @override
  int get hashCode => path.hashCode;
}
