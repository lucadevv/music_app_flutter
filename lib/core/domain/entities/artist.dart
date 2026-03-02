import 'package:equatable/equatable.dart';

/// Entidad de dominio unificada para un artista.
///
/// Esta es la entidad canónica que debe usarse en toda la app.
class Artist extends Equatable {
  /// ID único del artista
  final String id;

  /// Nombre del artista
  final String name;

  /// URL de la miniatura
  final String? thumbnail;

  /// URL de la miniatura de alta calidad
  final String? highThumbnail;

  /// Lista de miniaturas en diferentes tamaños
  final List<ArtistThumbnail> thumbnails;

  /// Número de oyentes mensuales
  final int? monthlyListeners;

  /// Número de oyentes mensuales formateado
  final String? monthlyListenersFormatted;

  /// Descripción del artista
  final String? description;

  /// Canciones más populares del artista
  final List<ArtistSong> topSongs;

  /// Álbumes del artista
  final List<ArtistAlbum> albums;

  /// Géneros musicales
  final List<String> genres;

  /// Indica si el artista está verificado
  final bool isVerified;

  const Artist({
    required this.id,
    required this.name,
    this.thumbnail,
    this.highThumbnail,
    this.thumbnails = const [],
    this.monthlyListeners,
    this.monthlyListenersFormatted,
    this.description,
    this.topSongs = const [],
    this.albums = const [],
    this.genres = const [],
    this.isVerified = false,
  });

  /// Obtiene la mejor URL de thumbnail disponible
  String? get bestThumbnail =>
      highThumbnail ??
      thumbnail ??
      (thumbnails.isNotEmpty ? thumbnails.last.url : null);

  /// Crea una copia con campos modificados
  Artist copyWith({
    String? id,
    String? name,
    String? thumbnail,
    String? highThumbnail,
    List<ArtistThumbnail>? thumbnails,
    int? monthlyListeners,
    String? monthlyListenersFormatted,
    String? description,
    List<ArtistSong>? topSongs,
    List<ArtistAlbum>? albums,
    List<String>? genres,
    bool? isVerified,
  }) {
    return Artist(
      id: id ?? this.id,
      name: name ?? this.name,
      thumbnail: thumbnail ?? this.thumbnail,
      highThumbnail: highThumbnail ?? this.highThumbnail,
      thumbnails: thumbnails ?? this.thumbnails,
      monthlyListeners: monthlyListeners ?? this.monthlyListeners,
      monthlyListenersFormatted:
          monthlyListenersFormatted ?? this.monthlyListenersFormatted,
      description: description ?? this.description,
      topSongs: topSongs ?? this.topSongs,
      albums: albums ?? this.albums,
      genres: genres ?? this.genres,
      isVerified: isVerified ?? this.isVerified,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    thumbnail,
    highThumbnail,
    thumbnails,
    monthlyListeners,
    monthlyListenersFormatted,
    description,
    topSongs,
    albums,
    genres,
    isVerified,
  ];
}

/// Miniatura de artista en diferentes tamaños
class ArtistThumbnail extends Equatable {
  final String url;
  final int width;
  final int height;

  const ArtistThumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  @override
  List<Object?> get props => [url, width, height];
}

/// Canción de un artista (simplificada)
class ArtistSong extends Equatable {
  final String videoId;
  final String title;
  final String? thumbnail;
  final int durationSeconds;
  final int views;

  const ArtistSong({
    required this.videoId,
    required this.title,
    this.thumbnail,
    required this.durationSeconds,
    this.views = 0,
  });

  /// Duración formateada
  String get formattedDuration {
    final minutes = durationSeconds ~/ 60;
    final seconds = durationSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }

  /// Vistas formateadas
  String get formattedViews {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  @override
  List<Object?> get props => [
    videoId,
    title,
    thumbnail,
    durationSeconds,
    views,
  ];
}

/// Álbum de un artista
class ArtistAlbum extends Equatable {
  final String id;
  final String title;
  final String? thumbnail;
  final int year;
  final int songCount;
  final String? type; // album, single, ep

  const ArtistAlbum({
    required this.id,
    required this.title,
    this.thumbnail,
    required this.year,
    required this.songCount,
    this.type,
  });

  @override
  List<Object?> get props => [id, title, thumbnail, year, songCount, type];
}
