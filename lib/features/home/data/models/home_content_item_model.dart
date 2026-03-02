import 'package:music_app/features/search/data/models/search_album_model.dart';
import 'package:music_app/features/search/data/models/search_artist_model.dart';
import 'package:music_app/features/search/data/models/thumbnail_model.dart';

import '../../domain/entities/home_content_item.dart';

/// Modelo para HomeContentItem
class HomeContentItemModel extends HomeContentItem {
  const HomeContentItemModel({
    required super.title,
    required super.thumbnails,
    required super.artists,
    super.videoId,
    super.playlistId,
    super.isExplicit,
    super.views,
    super.album,
    super.description,
    super.streamUrl,
    super.thumbnail,
  });

  factory HomeContentItemModel.fromJson(Map<String, dynamic> json) {
    return HomeContentItemModel(
      title: json['title'] as String? ?? '',
      videoId: json['videoId'] as String?,
      playlistId: json['playlistId'] as String?,
      thumbnails:
          (json['thumbnails'] as List<dynamic>?)
              ?.map(
                (item) => ThumbnailModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      isExplicit: json['isExplicit'] as bool? ?? false,
      artists:
          (json['artists'] as List<dynamic>?)
              ?.map(
                (item) =>
                    SearchArtistModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      views: json['views'] as String? ?? '0',
      album: json['album'] != null
          ? SearchAlbumModel.fromJson(json['album'] as Map<String, dynamic>)
          : null,
      description: json['description'] as String?,
      streamUrl: json['stream_url'] as String?,
      thumbnail: json['thumbnail'] != null
          ? ThumbnailModel.fromJson(json['thumbnail'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (videoId != null) 'videoId': videoId,
      if (playlistId != null) 'playlistId': playlistId,
      'thumbnails': thumbnails
          .map((t) => (t as ThumbnailModel).toJson())
          .toList(),
      'isExplicit': isExplicit,
      'artists': artists.map((a) => (a as SearchArtistModel).toJson()).toList(),
      'views': views,
      if (album != null) 'album': (album as SearchAlbumModel).toJson(),
      if (description != null) 'description': description,
      if (streamUrl != null) 'stream_url': streamUrl,
      if (thumbnail != null)
        'thumbnail': (thumbnail as ThumbnailModel).toJson(),
    };
  }
}
