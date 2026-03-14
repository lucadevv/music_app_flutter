import 'package:equatable/equatable.dart';
import 'package:music_app/features/search/domain/entities/album.dart';
import 'package:music_app/features/search/domain/entities/artist.dart';
import 'package:music_app/features/search/domain/entities/thumbnail.dart';

/// Tipo de contenido en las secciones del home
enum HomeContentType {
  song,
  album,
  playlist,
  unknown,
}

/// Entidad para items de contenido en las secciones de home
///
/// Puede ser:
/// - Canción: tiene videoId
/// - Álbum: tiene browseId y type="Album"
/// - Playlist: tiene playlistId
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar un item de contenido del home
class HomeContentItem extends Equatable {
  final String title;
  final String? videoId;
  final String? playlistId;
  final String? browseId; // Para albums
  final String? audioPlaylistId; // Para albums
  final String? type; // "Album", etc.
  final String? videoType; // "MUSIC_VIDEO_TYPE_ATV", etc.
  final List<Thumbnail> thumbnails;
  final bool isExplicit;
  final List<SearchArtist> artists;
  final String views;
  final SearchAlbum? album;
  final String? description; // Para playlists
  final String?
      streamUrl; // URL de streaming (viene del endpoint con include_stream_urls=true)
  final Thumbnail?
      thumbnail; // Thumbnail de mejor calidad (viene junto con stream_url)

  const HomeContentItem({
    required this.title,
    required this.thumbnails, required this.artists, this.videoId,
    this.playlistId,
    this.browseId,
    this.audioPlaylistId,
    this.type,
    this.videoType,
    this.isExplicit = false,
    this.views = '0',
    this.album,
    this.description,
    this.streamUrl,
    this.thumbnail,
  });

  /// Determina el tipo de contenido basado en los IDs presentes
  ///
  /// PATTERN: Factory Method - deduce el tipo de forma limpia
  HomeContentType get contentType {
    if (videoId != null && videoId!.isNotEmpty) {
      return HomeContentType.song;
    }
    if (browseId != null && browseId!.isNotEmpty) {
      return HomeContentType.album;
    }
    if (playlistId != null && playlistId!.isNotEmpty) {
      return HomeContentType.playlist;
    }
    return HomeContentType.unknown;
  }

  /// Verifica si es una canción reproducible
  bool get isPlayable => contentType == HomeContentType.song && streamUrl != null;

  /// Verifica si es una canción (legacy - usar contentType)
  bool get isSong => videoId != null && videoId!.isNotEmpty;

  /// Verifica si es una playlist (legacy - usar contentType)
  bool get isPlaylist => playlistId != null && playlistId!.isNotEmpty;

  /// Verifica si es un álbum
  bool get isAlbum => browseId != null && browseId!.isNotEmpty;

  /// Método de Dominio: Retorna true si este item hace match con un string de búsqueda.
  /// Evita que la UI tenga que implementar algoritmos de filtrado local.
  bool matchesQuery(String query) {
    if (query.trim().isEmpty) return true;
    final lowerQuery = query.toLowerCase();
    
    final matchesTitle = title.toLowerCase().contains(lowerQuery);
    final matchesArtist = artists.any((a) => a.name.toLowerCase().contains(lowerQuery));

    return matchesTitle || matchesArtist;
  }

  /// Copia con nuevos valores (PATTERN: Builder / CopyWith)
  HomeContentItem copyWith({
    String? title,
    String? videoId,
    String? playlistId,
    String? browseId,
    String? audioPlaylistId,
    String? type,
    String? videoType,
    List<Thumbnail>? thumbnails,
    bool? isExplicit,
    List<SearchArtist>? artists,
    String? views,
    SearchAlbum? album,
    String? description,
    String? streamUrl,
    Thumbnail? thumbnail,
  }) {
    return HomeContentItem(
      title: title ?? this.title,
      videoId: videoId ?? this.videoId,
      playlistId: playlistId ?? this.playlistId,
      browseId: browseId ?? this.browseId,
      audioPlaylistId: audioPlaylistId ?? this.audioPlaylistId,
      type: type ?? this.type,
      videoType: videoType ?? this.videoType,
      thumbnails: thumbnails ?? this.thumbnails,
      isExplicit: isExplicit ?? this.isExplicit,
      artists: artists ?? this.artists,
      views: views ?? this.views,
      album: album ?? this.album,
      description: description ?? this.description,
      streamUrl: streamUrl ?? this.streamUrl,
      thumbnail: thumbnail ?? this.thumbnail,
    );
  }

  @override
  List<Object?> get props => [
        title,
        videoId,
        playlistId,
        browseId,
        audioPlaylistId,
        type,
        videoType,
        thumbnails,
        isExplicit,
        artists,
        views,
        album,
        description,
        streamUrl,
        thumbnail,
      ];
}
