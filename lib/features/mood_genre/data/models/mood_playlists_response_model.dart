import 'package:music_app/features/mood_genre/domain/entities/mood_playlists_response.dart';
import 'mood_playlist_model.dart';

/// Modelo para la respuesta de playlists de mood/genre
class MoodPlaylistsResponseModel extends MoodPlaylistsResponse {
  const MoodPlaylistsResponseModel({
    required super.playlists,
    required super.genreName,
    required super.params,
    super.message,
    super.usage,
    super.method,
  });

  factory MoodPlaylistsResponseModel.fromJson(Map<String, dynamic> json) {
    return MoodPlaylistsResponseModel(
      playlists: (json['playlists'] as List<dynamic>?)
              ?.map((e) => MoodPlaylistModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      genreName: json['genre_name'] as String? ?? '',
      params: json['params'] as String? ?? '',
      message: json['message'] as String?,
      usage: json['usage'] as String?,
      method: json['method'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlists': playlists.map((p) => (p as MoodPlaylistModel).toJson()).toList(),
      'genre_name': genreName,
      'params': params,
      if (message != null) 'message': message,
      if (usage != null) 'usage': usage,
      if (method != null) 'method': method,
    };
  }
}
