import 'package:audio_service/audio_service.dart';
import 'package:equatable/equatable.dart';
import 'package:music_app/features/playlist/domain/entities/playlist_track.dart';
import 'package:music_app/features/search/domain/entities/album.dart';
import 'package:music_app/features/search/domain/entities/artist.dart';
import 'package:music_app/features/search/domain/entities/song.dart';
import 'package:music_app/features/search/domain/entities/thumbnail.dart';

/// Entidad genérica para datos de reproducción actual
/// Puede ser construida desde Song o con datos individuales
/// 
/// Esta entidad sigue el principio de Single Responsibility (SOLID):
/// - Responsable única: Representar los datos necesarios para reproducir una canción
/// - Inmutable: Todos los campos son final para garantizar inmutabilidad
/// - Reutilizable: Puede construirse desde diferentes fuentes (Song, datos básicos)
class NowPlayingData extends Equatable {
  final String videoId;
  final String title;
  final List<SearchArtist> artists;
  final SearchAlbum album;
  final String duration;
  final int durationSeconds;
  final String views;
  final bool isExplicit;
  final bool inLibrary;
  final List<Thumbnail> thumbnails;
  final String? streamUrl; // URL de streaming (viene del endpoint con include_stream_urls=true)
  final Thumbnail? thumbnail; // Thumbnail de mejor calidad (viene junto con stream_url)

  const NowPlayingData({
    required this.videoId,
    required this.title,
    required this.artists,
    required this.album,
    required this.duration,
    required this.durationSeconds,
    required this.views,
    required this.isExplicit,
    required this.inLibrary,
    required this.thumbnails,
    this.streamUrl,
    this.thumbnail,
  });

  /// Constructor desde Song
  factory NowPlayingData.fromSong(Song song) {
    return NowPlayingData(
      videoId: song.videoId,
      title: song.title,
      artists: song.artists,
      album: song.album,
      duration: song.duration,
      durationSeconds: song.durationSeconds,
      views: song.views,
      isExplicit: song.isExplicit,
      inLibrary: song.inLibrary,
      thumbnails: song.thumbnails,
      streamUrl: song.streamUrl,
      thumbnail: song.thumbnail, // Usar thumbnail de mejor calidad si está disponible
    );
  }

  /// Constructor desde PlaylistTrack
  factory NowPlayingData.fromPlaylistTrack(PlaylistTrack track) {
    // Si no hay videoId, usar un valor por defecto (no debería pasar en producción)
    final videoId = track.videoId ?? 'unknown';
    
    // Crear un SearchAlbum si no existe
    final album = track.album ??
        const SearchAlbum(name: 'Unknown Album', id: '');

    return NowPlayingData(
      videoId: videoId,
      title: track.title,
      artists: track.artists,
      album: album,
      duration: track.duration,
      durationSeconds: track.durationSeconds,
      views: track.views ?? '0',
      isExplicit: track.isExplicit,
      inLibrary: track.inLibrary ?? false,
      thumbnails: track.thumbnails,
      streamUrl: track.streamUrl,
      thumbnail: track.thumbnail, // Usar thumbnail de mejor calidad si está disponible
    );
  }

  /// Constructor con datos básicos (para casos donde no tenemos Song completo)
  factory NowPlayingData.fromBasic({
    required String videoId,
    required String title,
    required List<String> artistNames,
    required String albumName,
    required String duration, String? albumId,
    int? durationSeconds,
    String views = '0',
    bool isExplicit = false,
    bool inLibrary = false,
    List<String>? thumbnailUrls,
    List<Thumbnail>? thumbnails, // Lista de thumbnails con dimensiones reales
    String? streamUrl, // URL de streaming (viene del endpoint con include_stream_urls=true)
    String? thumbnailUrl, // Thumbnail de mejor calidad (URL string - fallback)
    Thumbnail? thumbnail, // Thumbnail de mejor calidad (objeto completo con dimensiones reales)
  }) {
    // Priorizar thumbnail completo si está disponible, luego thumbnailUrl, luego thumbnails
    final bestThumbnail = thumbnail ?? 
        (thumbnailUrl != null 
            ? Thumbnail(url: thumbnailUrl, width: 544, height: 544) // Dimensiones típicas de mejor calidad
            : null);
    
    // Crear lista de thumbnails: priorizar thumbnails con dimensiones reales
    final thumbnailsList = thumbnails ?? 
        (thumbnailUrl != null
            ? [Thumbnail(url: thumbnailUrl, width: 544, height: 544)]
            : (thumbnailUrls
                    ?.map((url) => Thumbnail(url: url, width: 120, height: 120))
                    .toList() ??
                []));

    return NowPlayingData(
      videoId: videoId,
      title: title,
      artists: artistNames
          .map((name) => SearchArtist(name: name, id: ''))
          .toList(),
      album: SearchAlbum(name: albumName, id: albumId ?? ''),
      duration: duration,
      durationSeconds: durationSeconds ?? 0,
      views: views,
      isExplicit: isExplicit,
      inLibrary: inLibrary,
      thumbnails: thumbnailsList,
      streamUrl: streamUrl,
      thumbnail: bestThumbnail,
    );
  }

  /// Obtener nombres de artistas como string
  /// 
  /// Utiliza un getter computado para evitar duplicación de lógica
  String get artistsNames => artists.map((a) => a.name).join(', ');

  /// Simple alias for duration in UI strings
  String get formattedDuration => duration;

  /// Obtener la mejor thumbnail disponible
  /// 
  /// Prioridad:
  /// 1. thumbnail (de mejor calidad, viene con stream_url)
  /// 2. La más grande de thumbnails
  /// 
  /// Retorna null si no hay thumbnails disponibles
  Thumbnail? get bestThumbnail {
    // Priorizar thumbnail de mejor calidad si está disponible
    if (thumbnail != null) return thumbnail;
    
    // Si no, usar la más grande de thumbnails
    if (thumbnails.isEmpty) return null;
    return thumbnails.last; // La última suele ser la más grande
  }

  /// Convierte NowPlayingData a MediaItem para notificaciones
  /// 
  /// Esto es necesario para que las notificaciones y controles
  /// en pantalla de bloqueo muestren la información correcta
  MediaItem toMediaItem() {
    return MediaItem(
      id: videoId,
      album: album.name,
      title: title,
      artist: artistsNames,
      duration: durationSeconds > 0 ? Duration(seconds: durationSeconds) : null,
      artUri: bestThumbnail != null ? Uri.tryParse(bestThumbnail!.url) : null,
      extras: {
        'videoId': videoId,
        'streamUrl': streamUrl,
      },
    );
  }

  /// Verifica si tiene información completa
  /// 
  /// Útil para validar que la entidad tiene todos los datos necesarios
  bool get hasCompleteData {
    return videoId.isNotEmpty &&
        title.isNotEmpty &&
        artists.isNotEmpty &&
        album.name.isNotEmpty &&
        duration.isNotEmpty;
  }

  @override
  List<Object?> get props => [
        videoId,
        title,
        artists,
        album,
        duration,
        durationSeconds,
        views,
        isExplicit,
        inLibrary,
        thumbnails,
        streamUrl,
        thumbnail,
      ];
}
