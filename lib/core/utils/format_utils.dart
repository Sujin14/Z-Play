import '../models/song_model.dart';

const _msPerMinute = 60000;
const _minutesPerHour = 60;

// m:ss, or h:mm:ss once a track passes an hour.
String formatClock(Duration duration) {
  final hours = duration.inHours;
  final minutes = duration.inMinutes.remainder(60);
  final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
  if (hours > 0) {
    return '$hours:${minutes.toString().padLeft(2, '0')}:$seconds';
  }
  return '${duration.inMinutes}:$seconds';
}

// "41 min" or "1 h 6 min". Songs with an unknown length are skipped, and an
// empty string means nothing had a known length.
String formatTotalDuration(List<Song> songs) {
  final totalMs = songs.fold<int>(
      0, (sum, song) => sum + (song.durationMs > 0 ? song.durationMs : 0));
  if (totalMs <= 0) return '';
  var minutes = (totalMs / _msPerMinute).round();
  if (minutes < 1) minutes = 1;
  final hours = minutes ~/ _minutesPerHour;
  final rest = minutes % _minutesPerHour;
  if (hours == 0) return '$minutes min';
  return rest == 0 ? '$hours h' : '$hours h $rest min';
}

// "12 tracks · 41 min", dropping the duration when it is unknown.
String tracksLabel(List<Song> songs, {String noun = 'track'}) {
  final count = '${songs.length} ${songs.length == 1 ? noun : '${noun}s'}';
  final duration = formatTotalDuration(songs);
  return duration.isEmpty ? count : '$count · $duration';
}

// Countdown as minutes:seconds, with minutes allowed past 59 (e.g. "60:00").
String formatCountdown(Duration remaining) {
  final seconds = remaining.inSeconds.remainder(60).toString().padLeft(2, '0');
  return '${remaining.inMinutes}:$seconds';
}

// Whole rates drop the decimal: "2x", not "2.0x".
String formatSpeed(double rate) {
  final whole = rate == rate.roundToDouble();
  return whole ? '${rate.toInt()}x' : '${rate}x';
}
