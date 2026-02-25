import '../../domain/entities/recent_search.dart';
import 'song_model.dart';

/// Modelo de datos para una búsqueda reciente
class RecentSearchModel extends RecentSearch {
  const RecentSearchModel({
    required super.id,
    required super.videoId,
    required super.songData,
    required super.createdAt,
    required super.lastSearchedAt,
  });

  factory RecentSearchModel.fromJson(Map<String, dynamic> json) {
    // Manejar songData que puede venir como Map o como objeto
    Map<String, dynamic> songDataMap;
    if (json['songData'] is Map<String, dynamic>) {
      songDataMap = json['songData'] as Map<String, dynamic>;
    } else if (json['songData'] != null) {
      // Si viene como otro tipo de objeto, intentar convertirlo
      try {
        songDataMap = Map<String, dynamic>.from(json['songData'] as Map);
      } catch (e) {
        // Si falla, crear un objeto vacío
        songDataMap = {};
      }
    } else {
      songDataMap = {};
    }

    return RecentSearchModel(
      id: json['id'] as String? ?? '',
      videoId: json['videoId'] as String? ?? '',
      songData: SongModel.fromJson(songDataMap),
      createdAt: DateTime.parse(json['createdAt'] as String? ?? DateTime.now().toIso8601String()),
      lastSearchedAt: DateTime.parse(json['lastSearchedAt'] as String? ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'videoId': videoId,
      'songData': (songData as SongModel).toJson(),
      'createdAt': createdAt.toIso8601String(),
      'lastSearchedAt': lastSearchedAt.toIso8601String(),
    };
  }
}
