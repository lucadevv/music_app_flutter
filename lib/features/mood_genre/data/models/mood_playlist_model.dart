import 'package:music_app/features/mood_genre/domain/entities/mood_playlist.dart';
import 'package:music_app/features/search/data/models/thumbnail_model.dart';

/// Modelo para una playlist de mood/genre
class MoodPlaylistModel extends MoodPlaylist {
  const MoodPlaylistModel({
    required super.title,
    required super.itemCount,
    required super.author,
    required super.browseId,
    required super.thumbnails,
    required super.category,
    required super.resultType,
  });

  factory MoodPlaylistModel.fromJson(Map<String, dynamic> json) {
    return MoodPlaylistModel(
      title: json['title'] as String? ?? '',
      itemCount: json['itemCount'] as String? ?? '0',
      author: json['author'] as String? ?? '',
      // La API puede retornar 'playlistId' o 'browseId'
      browseId: json['browseId'] as String? ?? 
                json['playlistId'] as String? ?? '',
      thumbnails: (json['thumbnails'] as List<dynamic>?)
              ?.map((e) => ThumbnailModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      category: json['category'] as String? ?? '',
      resultType: json['resultType'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'itemCount': itemCount,
      'author': author,
      'browseId': browseId,
      'thumbnails': thumbnails.map((t) => (t as ThumbnailModel).toJson()).toList(),
      'category': category,
      'resultType': resultType,
    };
  }
}
