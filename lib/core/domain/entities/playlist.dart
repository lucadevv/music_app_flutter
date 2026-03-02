import 'package:equatable/equatable.dart';

/// Entidad de dominio unificada para una playlist.
///
/// Esta es la entidad canónica que debe usarse en toda la app.
class Playlist extends Equatable {
  /// ID único de la playlist
  final String id;

  /// Título de la playlist
  final String title;

  /// Descripción
  final String? description;

  /// URL de la miniatura
  final String? thumbnail;

  /// URL de la miniatura de alta calidad
  final String? highThumbnail;

  /// Lista de miniaturas en diferentes tamaños
  final List<PlaylistThumbnail> thumbnails;

  /// Creador/Autor de la playlist
  final PlaylistAuthor? author;

  /// Número de vistas
  final int? views;

  /// Número de vistas formateado
  final String? viewsFormatted;

  /// Duración total en segundos
  final int durationSeconds;

  /// Duración formateada
  final String duration;

  /// Número de canciones
  final int trackCount;

  /// Privacidad (public, private, unlisted)
  final String privacy;

  /// Año de creación/actualización
  final String? year;

  /// Si el usuario es el owner
  final bool isOwned;

  /// Si la playlist está likeada por el usuario
  final bool isLiked;

  /// Canciones de la playlist
  final List<PlaylistTrack> tracks;

  /// Géneros asociados
  final List<String> genres;

  /// Tipo de playlist (playlist, album, mix)
  final String? type;

  const Playlist({
    required this.id,
    required this.title,
    this.description,
    this.thumbnail,
    this.highThumbnail,
    this.thumbnails = const [],
    this.author,
    this.views,
    this.viewsFormatted,
    this.durationSeconds = 0,
    this.duration = '0:00',
    this.trackCount = 0,
    this.privacy = 'public',
    this.year,
    this.isOwned = false,
    this.isLiked = false,
    this.tracks = const [],
    this.genres = const [],
    this.type,
  });

  /// Obtiene la mejor URL de thumbnail disponible
  String? get bestThumbnail =>
      highThumbnail ??
      thumbnail ??
      (thumbnails.isNotEmpty ? thumbnails.last.url : null);

  /// Duración total formateada
  String get formattedDuration {
    if (durationSeconds > 0) {
      final hours = durationSeconds ~/ 3600;
      final minutes = (durationSeconds % 3600) ~/ 60;
      if (hours > 0) {
        return '$hours h $minutes min';
      }
      return '$minutes min';
    }
    return duration;
  }

  /// Crea una copia con campos modificados
  Playlist copyWith({
    String? id,
    String? title,
    String? description,
    String? thumbnail,
    String? highThumbnail,
    List<PlaylistThumbnail>? thumbnails,
    PlaylistAuthor? author,
    int? views,
    String? viewsFormatted,
    int? durationSeconds,
    String? duration,
    int? trackCount,
    String? privacy,
    String? year,
    bool? isOwned,
    bool? isLiked,
    List<PlaylistTrack>? tracks,
    List<String>? genres,
    String? type,
  }) {
    return Playlist(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      thumbnail: thumbnail ?? this.thumbnail,
      highThumbnail: highThumbnail ?? this.highThumbnail,
      thumbnails: thumbnails ?? this.thumbnails,
      author: author ?? this.author,
      views: views ?? this.views,
      viewsFormatted: viewsFormatted ?? this.viewsFormatted,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      duration: duration ?? this.duration,
      trackCount: trackCount ?? this.trackCount,
      privacy: privacy ?? this.privacy,
      year: year ?? this.year,
      isOwned: isOwned ?? this.isOwned,
      isLiked: isLiked ?? this.isLiked,
      tracks: tracks ?? this.tracks,
      genres: genres ?? this.genres,
      type: type ?? this.type,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    description,
    thumbnail,
    highThumbnail,
    thumbnails,
    author,
    views,
    viewsFormatted,
    durationSeconds,
    duration,
    trackCount,
    privacy,
    year,
    isOwned,
    isLiked,
    tracks,
    genres,
    type,
  ];
}

/// Miniatura de playlist en diferentes tamaños
class PlaylistThumbnail extends Equatable {
  final String url;
  final int width;
  final int height;

  const PlaylistThumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [url, width, height];
}

/// Autor/Creador de una playlist
class PlaylistAuthor extends Equatable {
  final String name;
  final String? id;
  final String? thumbnail;

  const PlaylistAuthor({required this.name, this.id, this.thumbnail});

  @override
  List<Object?> get props => [name, id, thumbnail];
}

/// Canción en una playlist
class PlaylistTrack extends Equatable {
  /// Video ID (YouTube)
  final String? videoId;

  /// Título de la canción
  final String title;

  /// Artistas
  final List<PlaylistArtist> artists;

  /// Álbum
  final PlaylistAlbum? album;

  /// Estado de like (LIKE, INDIFFERENT, DISLIKE)
  final String? likeStatus;

  /// Si está en la biblioteca
  final bool? inLibrary;

  /// Si está fijada para escuchar de nuevo
  final bool? pinnedToListenAgain;

  /// Miniaturas
  final List<PlaylistThumbnail> thumbnails;

  /// Si está disponible para reproducir
  final bool isAvailable;

  /// Si es contenido explícito
  final bool isExplicit;

  /// Tipo de video
  final String? videoType;

  /// Vistas formateadas
  final String? views;

  /// Duración
  final String duration;

  /// Duración en segundos
  final int durationSeconds;

  /// URL de streaming
  final String? streamUrl;

  /// Thumbnail de alta calidad
  final String? thumbnail;

  const PlaylistTrack({
    this.videoId,
    required this.title,
    this.artists = const [],
    this.album,
    this.likeStatus,
    this.inLibrary,
    this.pinnedToListenAgain,
    this.thumbnails = const [],
    this.isAvailable = true,
    this.isExplicit = false,
    this.videoType,
    this.views,
    this.duration = '0:00',
    this.durationSeconds = 0,
    this.streamUrl,
    this.thumbnail,
  });

  /// Nombre del artista principal
  String get artistName =>
      artists.isNotEmpty ? artists.first.name : 'Unknown Artist';

  /// Nombres de todos los artistas
  String get artistNames => artists.map((a) => a.name).join(', ');

  /// Mejor thumbnail
  String? get bestThumbnail =>
      thumbnail ?? (thumbnails.isNotEmpty ? thumbnails.last.url : null);

  /// Puede reproducirse
  bool get canPlay => isAvailable && streamUrl != null && streamUrl!.isNotEmpty;

  @override
  List<Object?> get props => [
    videoId,
    title,
    artists,
    album,
    likeStatus,
    inLibrary,
    pinnedToListenAgain,
    thumbnails,
    isAvailable,
    isExplicit,
    videoType,
    views,
    duration,
    durationSeconds,
    streamUrl,
    thumbnail,
  ];
}

/// Artista en una playlist
class PlaylistArtist extends Equatable {
  final String id;
  final String name;

  const PlaylistArtist({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

/// Álbum en una playlist
class PlaylistAlbum extends Equatable {
  final String id;
  final String name;

  const PlaylistAlbum({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}
