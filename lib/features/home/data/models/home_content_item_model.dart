import 'package:music_app/features/home/domain/entities/home_content_item.dart';
import 'package:music_app/features/search/data/models/search_album_model.dart';
import 'package:music_app/features/search/data/models/search_artist_model.dart';
import 'package:music_app/features/search/data/models/thumbnail_model.dart';

/// Modelo para HomeContentItem
///
/// Actualizado para soportar:
/// - Canciones (videoId)
/// - Álbumes (browseId, audioPlaylistId, type)
/// - Playlists (playlistId)
/// - Stream URLs para reproducción directa
class HomeContentItemModel extends HomeContentItem {
  const HomeContentItemModel({
    required super.title,
    
    required super.thumbnails, required super.artists, super.videoId,
    super.playlistId,
    super.browseId,
    super.audioPlaylistId,
    super.type,
    super.videoType,
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
      browseId: json['browseId'] as String?,
      audioPlaylistId: json['audioPlaylistId'] as String?,
      type: json['type'] as String?,
      videoType: json['videoType'] as String?,
      thumbnails: (json['thumbnails'] as List<dynamic>?)
              ?.map((item) => ThumbnailModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      isExplicit: json['isExplicit'] as bool? ?? false,
      artists: (json['artists'] as List<dynamic>?)
              ?.map((item) => SearchArtistModel.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      views: json['views'] as String? ?? '0',
      album: json['album'] != null
          ? SearchAlbumModel.fromJson(json['album'] as Map<String, dynamic>)
          : null,
      description: json['description'] as String?,
      streamUrl: json['stream_url'] as String?,
      thumbnail: _parseThumbnail(json),
    );
  }

  /// Parser para thumbnail que puede ser String o Map
  static ThumbnailModel? _parseThumbnail(Map<String, dynamic> json) {
    final thumbnail = json['thumbnail'];
    if (thumbnail == null) return null;
    if (thumbnail is String) {
      // Si es string, crear un Thumbnail con esa URL
      return ThumbnailModel(
        url: thumbnail,
        width: 800,
        height: 800,
      );
    }
    if (thumbnail is Map<String, dynamic>) {
      return ThumbnailModel.fromJson(thumbnail);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      if (videoId != null) 'videoId': videoId,
      if (playlistId != null) 'playlistId': playlistId,
      if (browseId != null) 'browseId': browseId,
      if (audioPlaylistId != null) 'audioPlaylistId': audioPlaylistId,
      if (type != null) 'type': type,
      if (videoType != null) 'videoType': videoType,
      'thumbnails': thumbnails.map((t) => (t as ThumbnailModel).toJson()).toList(),
      'isExplicit': isExplicit,
      'artists': artists.map((a) => (a as SearchArtistModel).toJson()).toList(),
      'views': views,
      if (album != null) 'album': (album as SearchAlbumModel).toJson(),
      if (description != null) 'description': description,
      if (streamUrl != null) 'stream_url': streamUrl,
      if (thumbnail != null) 'thumbnail': (thumbnail as ThumbnailModel).toJson(),
    };
  }

  /// Convierte el modelo a la entidad del dominio
  HomeContentItem toEntity() {
    return HomeContentItem(
      title: title,
      videoId: videoId,
      playlistId: playlistId,
      browseId: browseId,
      audioPlaylistId: audioPlaylistId,
      type: type,
      videoType: videoType,
      thumbnails: thumbnails,
      isExplicit: isExplicit,
      artists: artists,
      views: views,
      album: album,
      description: description,
      streamUrl: streamUrl,
      thumbnail: thumbnail,
    );
  }

  /// Crea el modelo desde la entidad del dominio
  factory HomeContentItemModel.fromEntity(HomeContentItem entity) {
    return HomeContentItemModel(
      title: entity.title,
      videoId: entity.videoId,
      playlistId: entity.playlistId,
      browseId: entity.browseId,
      audioPlaylistId: entity.audioPlaylistId,
      type: entity.type,
      videoType: entity.videoType,
      thumbnails: entity.thumbnails,
      isExplicit: entity.isExplicit,
      artists: entity.artists,
      views: entity.views,
      album: entity.album,
      description: entity.description,
      streamUrl: entity.streamUrl,
      thumbnail: entity.thumbnail,
    );
  }
}
