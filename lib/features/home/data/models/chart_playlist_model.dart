import '../../domain/entities/chart_playlist.dart';
import '../../../search/data/models/thumbnail_model.dart';

/// Modelo para ChartPlaylist
class ChartPlaylistModel extends ChartPlaylist {
  const ChartPlaylistModel({
    required super.title,
    required super.playlistId,
    required super.thumbnails,
  });

  factory ChartPlaylistModel.fromJson(Map<String, dynamic> json) {
    return ChartPlaylistModel(
      title: json['title'] as String? ?? '',
      playlistId: json['playlistId'] as String? ?? '',
      thumbnails: (json['thumbnails'] as List<dynamic>?)
              ?.map((item) => ThumbnailModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'playlistId': playlistId,
      'thumbnails': thumbnails.map((t) => (t as ThumbnailModel).toJson()).toList(),
    };
  }
}
