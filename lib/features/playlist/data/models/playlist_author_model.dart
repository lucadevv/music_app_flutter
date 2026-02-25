import '../../domain/entities/playlist_author.dart';

/// Modelo de datos para el autor de una playlist
class PlaylistAuthorModel extends PlaylistAuthor {
  const PlaylistAuthorModel({
    required super.name,
    required super.id,
  });

  factory PlaylistAuthorModel.fromJson(Map<String, dynamic> json) {
    return PlaylistAuthorModel(
      name: json['name'] as String? ?? '',
      id: json['id'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'id': id,
    };
  }
}
