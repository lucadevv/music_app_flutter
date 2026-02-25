import 'mood_playlist.dart';

/// Entidad para la respuesta de playlists de mood/genre
class MoodPlaylistsResponse {
  final List<MoodPlaylist> playlists;
  final String genreName;
  final String params;
  final String? message;
  final String? usage;
  final String? method;

  const MoodPlaylistsResponse({
    required this.playlists,
    required this.genreName,
    required this.params,
    this.message,
    this.usage,
    this.method,
  });
}
