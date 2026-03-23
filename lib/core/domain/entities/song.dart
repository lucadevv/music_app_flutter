import 'package:equatable/equatable.dart';

/// Entidad de dominio unificada para una canción.
///
/// Esta es la entidad canónica que debe usarse en toda la app.
/// Las diferentes fuentes de datos (search, downloads, library, etc.)
/// deben mapear a esta entidad.
///
/// Usar esta entidad en:
/// - Presentación (UI)
/// - Casos de uso (Use Cases)
/// - Repositorios (interfaces de dominio)
class Song extends Equatable {
  /// Identificador único del video (YouTube videoId)
  final String videoId;

  /// Título de la canción
  final String title;

  /// Nombre del artista principal
  final String artist;

  /// Lista de nombres de artistas
  final List<String> artistNames;

  /// Nombre del álbum (opcional)
  final String? album;

  /// URL de la miniatura (thumbnail)
  final String? thumbnail;

  /// URL de la miniatura de alta calidad
  final String? highThumbnail;

  /// Lista de miniaturas en diferentes tamaños
  final List<Thumbnail> thumbnails;

  /// URL de streaming (puede ser null si no se ha obtenido)
  final String? streamUrl;

  /// Duración en segundos
  final int durationSeconds;

  /// Duración formateada (ej: "3:45")
  final String duration;

  /// Número de vistas (string formateado)
  final String? views;

  /// Indica si el contenido es explícito
  final bool isExplicit;

  /// Indica si la canción está en la biblioteca del usuario
  final bool inLibrary;

  /// Ruta local (para canciones descargadas)
  final String? localPath;

  /// Tamaño del archivo en bytes (para descargas)
  final int? fileSize;

  /// Fecha de descarga (para canciones descargadas)
  final DateTime? downloadedAt;

  const Song({
    required this.videoId,
    required this.title,
    required this.artist,
    this.artistNames = const [],
    this.album,
    this.thumbnail,
    this.highThumbnail,
    this.thumbnails = const [],
    this.streamUrl,
    this.durationSeconds = 0,
    this.duration = '0:00',
    this.views,
    this.inLibrary = false,
    this.isExplicit = false,
    this.localPath,
    this.fileSize,
    this.downloadedAt,
  });

  /// Crea una copia con campos modificados
  Song copyWith({
    String? videoId,
    String? title,
    String? artist,
    List<String>? artistNames,
    String? album,
    String? thumbnail,
    String? highThumbnail,
    List<Thumbnail>? thumbnails,
    String? streamUrl,
    int? durationSeconds,
    String? duration,
    String? views,
    bool? isExplicit,
    bool? inLibrary,
    String? localPath,
    int? fileSize,
    DateTime? downloadedAt,
  }) {
    return Song(
      videoId: videoId ?? this.videoId,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      artistNames: artistNames ?? this.artistNames,
      album: album ?? this.album,
      thumbnail: thumbnail ?? this.thumbnail,
      highThumbnail: highThumbnail ?? this.highThumbnail,
      thumbnails: thumbnails ?? this.thumbnails,
      streamUrl: streamUrl ?? this.streamUrl,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      duration: duration ?? this.duration,
      views: views ?? this.views,
      isExplicit: isExplicit ?? this.isExplicit,
      inLibrary: inLibrary ?? this.inLibrary,
      localPath: localPath ?? this.localPath,
      fileSize: fileSize ?? this.fileSize,
      downloadedAt: downloadedAt ?? this.downloadedAt,
    );
  }

  /// Obtiene la mejor URL de thumbnail disponible
  String? get bestThumbnail =>
      highThumbnail ??
      thumbnail ??
      (thumbnails.isNotEmpty ? thumbnails.last.url : null);

  /// Indica si la canción tiene URL de streaming
  bool get canPlay => streamUrl != null && streamUrl!.isNotEmpty;

  /// Indica si la canción está descargada localmente
  bool get isDownloaded => localPath != null && localPath!.isNotEmpty;

  /// Duración formateada
  String get durationFormatted {
    if (durationSeconds > 0) {
      final minutes = durationSeconds ~/ 60;
      final seconds = durationSeconds % 60;
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
    return duration;
  }

  /// Tamaño del archivo formateado (ej: "5.2 MB")
  String? get fileSizeFormatted {
    if (fileSize != null && fileSize! > 0) {
      final mb = fileSize! / (1024 * 1024);
      return '${mb.toStringAsFixed(1)} MB';
    }
    return null;
  }

  /// Convert the song to a JSON map for serialization
  Map<String, dynamic> toJson() {
    return {
      'videoId': videoId,
      'title': title,
      'artist': artist,
      'artistNames': artistNames,
      'album': album,
      'thumbnail': thumbnail,
      'highThumbnail': highThumbnail,
      'thumbnails': thumbnails.map((t) => t.toJson()).toList(),
      'streamUrl': streamUrl,
      'durationSeconds': durationSeconds,
      'duration': duration,
      'views': views,
      'isExplicit': isExplicit,
      'inLibrary': inLibrary,
      'localPath': localPath,
      'fileSize': fileSize,
      'downloadedAt': downloadedAt?.toIso8601String(),
    };
  }

  /// Create a Song from a JSON map
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      videoId: json['videoId'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artist: json['artist'] as String? ?? '',
      artistNames:
          (json['artistNames'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      album: json['album'] as String?,
      thumbnail: json['thumbnail'] as String?,
      highThumbnail: json['highThumbnail'] as String?,
      thumbnails:
          (json['thumbnails'] as List<dynamic>?)?.map((e) {
            final map = e as Map<String, dynamic>;
            return Thumbnail(
              url: map['url'] as String? ?? '',
              width: map['width'] as int? ?? 0,
              height: map['height'] as int? ?? 0,
            );
          }).toList() ??
          [],
      streamUrl: json['streamUrl'] as String?,
      durationSeconds: json['durationSeconds'] as int? ?? 0,
      duration: json['duration'] as String? ?? '0:00',
      views: json['views'] as String? ?? '0',
      isExplicit: json['isExplicit'] as bool? ?? false,
      inLibrary: json['inLibrary'] as bool? ?? false,
      localPath: json['localPath'] as String?,
      fileSize: json['fileSize'] as int?,
      downloadedAt: json['downloadedAt'] != null
          ? DateTime.parse(json['downloadedAt'] as String)
          : null,
    );
  }

  @override
  List<Object?> get props => [
    videoId,
    title,
    artist,
    artistNames,
    album,
    thumbnail,
    highThumbnail,
    thumbnails,
    streamUrl,
    durationSeconds,
    duration,
    views,
    isExplicit,
    inLibrary,
    localPath,
    fileSize,
    downloadedAt,
  ];
}

/// Representa una miniatura en diferentes tamaños
class Thumbnail extends Equatable {
  final String url;
  final int width;
  final int height;

  const Thumbnail({
    required this.url,
    required this.width,
    required this.height,
  });

  /// Convert the thumbnail to a JSON map for serialization
  Map<String, dynamic> toJson() {
    return {'url': url, 'width': width, 'height': height};
  }

  @override
  List<Object?> get props => [url, width, height];
}
