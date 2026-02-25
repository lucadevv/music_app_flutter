import 'package:flutter/foundation.dart';
import '../../../search/data/models/thumbnail_model.dart' show ThumbnailModel;
import '../../domain/entities/playlist_response.dart';
import 'playlist_author_model.dart' show PlaylistAuthorModel;
import 'playlist_track_model.dart' show PlaylistTrackModel;

/// Modelo de datos para la respuesta de una playlist
class PlaylistResponseModel extends PlaylistResponse {
  const PlaylistResponseModel({
    required super.owned,
    required super.id,
    required super.privacy,
    required super.description,
    required super.views,
    required super.duration,
    required super.trackCount,
    required super.title,
    required super.thumbnails,
    required super.author,
    required super.year,
    required super.related,
    required super.tracks,
    required super.durationSeconds,
  });

  /// Factory para parsear JSON
  /// Para playlists grandes, usar PlaylistResponseParsingIsolate.parseInIsolate()
  factory PlaylistResponseModel.fromJson(Map<String, dynamic> json) {
    try {
      // Parsear thumbnails de forma segura
      final thumbnailsList = <ThumbnailModel>[];
      if (json['thumbnails'] != null) {
        final thumbnailsData = json['thumbnails'];
        if (thumbnailsData is List) {
          for (var thumb in thumbnailsData) {
            if (thumb is Map<String, dynamic>) {
              try {
                thumbnailsList.add(ThumbnailModel.fromJson(thumb));
              } catch (e) {
                // Ignorar thumbnails inválidos
              }
            }
          }
        }
      }

      // Parsear author de forma segura
      PlaylistAuthorModel author;
      if (json['author'] != null && json['author'] is Map<String, dynamic>) {
        try {
          author = PlaylistAuthorModel.fromJson(json['author'] as Map<String, dynamic>);
        } catch (e) {
          author = const PlaylistAuthorModel(name: '', id: '');
        }
      } else {
        author = const PlaylistAuthorModel(name: '', id: '');
      }

      // Parsear tracks de forma segura
      final tracksList = <PlaylistTrackModel>[];
      if (json['tracks'] != null) {
        final tracksData = json['tracks'];
        if (tracksData is List) {
          for (var i = 0; i < tracksData.length; i++) {
            final track = tracksData[i];
            if (track is Map<String, dynamic>) {
              try {
                tracksList.add(PlaylistTrackModel.fromJson(track));
              } catch (e, stackTrace) {
                // Log del error pero continuar parseando el resto
                debugPrint('PlaylistResponseModel: Error parseando track $i: $e');
                debugPrint('PlaylistResponseModel: Track data: $track');
              }
            } else {
              debugPrint('PlaylistResponseModel: Track $i no es Map, tipo: ${track.runtimeType}');
            }
          }
        }
      }

      return PlaylistResponseModel(
        owned: json['owned'] as bool? ?? false,
        id: json['id'] as String? ?? '',
        privacy: json['privacy'] as String? ?? 'PUBLIC',
        description: json['description'] as String? ?? '',
        views: json['views'] as int? ?? 0,
        duration: json['duration'] as String? ?? '0:00',
        trackCount: json['trackCount'] as int? ?? 0,
        title: json['title'] as String? ?? '',
        thumbnails: thumbnailsList,
        author: author,
        year: json['year'] as String? ?? '',
        related: json['related'] as List<dynamic>? ?? [],
        tracks: tracksList,
        durationSeconds: json['duration_seconds'] as int? ?? 0,
      );
    } catch (e, stackTrace) {
      debugPrint('PlaylistResponseModel: Error general parseando JSON: $e');
      debugPrint('PlaylistResponseModel: Stack trace: $stackTrace');
      rethrow;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'owned': owned,
      'id': id,
      'privacy': privacy,
      'description': description,
      'views': views,
      'duration': duration,
      'trackCount': trackCount,
      'title': title,
      'thumbnails': thumbnails.map((thumb) => (thumb as ThumbnailModel).toJson()).toList(),
      'author': (author as PlaylistAuthorModel).toJson(),
      'year': year,
      'related': related,
      'tracks': tracks.map((track) => (track as PlaylistTrackModel).toJson()).toList(),
      'duration_seconds': durationSeconds,
    };
  }
}
