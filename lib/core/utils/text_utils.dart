import '../models/song_model.dart';

// First letter or digit of a name, in any script; "#" when the name starts
// with anything else.
String artistInitial(String name) {
  final trimmed = name.trim();
  if (trimmed.isEmpty) return '#';
  final first = String.fromCharCode(trimmed.runes.first).toUpperCase();
  return RegExp(r'[\p{L}\p{N}]', unicode: true).hasMatch(first) ? first : '#';
}

// The artist when every song shares one, otherwise "Various artists".
String albumArtist(List<Song> songs) {
  final artists = {for (final song in songs) song.artist};
  return artists.length == 1 ? artists.first : 'Various artists';
}

// "/storage/emulated/0/Music/Gym" -> "/Music/Gym". Display only; anything
// that acts on a folder must keep using the full path.
String shortStoragePath(String path) {
  final normalized = path.replaceAll('\\', '/');
  final match =
      RegExp(r'^/storage/(emulated/\d+|[^/]+)(?=/|$)').firstMatch(normalized);
  if (match == null) return normalized;
  final rest = normalized.substring(match.end);
  return rest.isEmpty ? '/' : rest;
}
