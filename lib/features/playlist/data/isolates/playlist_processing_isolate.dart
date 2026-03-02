import 'package:flutter/foundation.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/playlist/domain/entities/playlist_track.dart';

/// Helper para procesar playlists grandes en un isolate
///
/// Útil cuando una playlist tiene muchas canciones (>50) y la conversión
/// podría bloquear el hilo principal
class PlaylistProcessingIsolate {
  /// Procesa una lista de tracks y los convierte a NowPlayingData en un isolate
  ///
  /// [tracks] Lista de PlaylistTrack a convertir
  ///
  /// Retorna [List<NowPlayingData>]
  static Future<List<NowPlayingData>> processPlaylistInIsolate(
    List<PlaylistTrack> tracks,
  ) async {
    // Si la lista es pequeña, no vale la pena usar isolate
    // El overhead de crear el isolate es mayor que el beneficio
    if (tracks.length < 50) {
      return _processPlaylistSync(tracks);
    }

    try {
      // Usar compute para procesar en un isolate
      // compute maneja automáticamente la serialización
      // Nota: compute requiere que la función sea top-level o static
      // y que los datos sean serializables
      return await compute(_processPlaylistInIsolate, tracks);
    } catch (e) {
      // Si falla el isolate, usar el método síncrono como fallback
      if (kDebugMode) {
        debugPrint('Isolate falló, usando método síncrono: $e');
      }
      return _processPlaylistSync(tracks);
    }
  }

  /// Procesa la playlist de forma síncrona (para listas pequeñas)
  static List<NowPlayingData> _processPlaylistSync(List<PlaylistTrack> tracks) {
    return tracks
        .where(
          (track) =>
              track.videoId != null &&
              track.videoId!.isNotEmpty &&
              track.isAvailable,
        )
        .map(NowPlayingData.fromPlaylistTrack)
        .toList();
  }
}

/// Función top-level para procesar playlist en isolate
///
/// Esta función debe ser top-level para poder usarse con compute()
List<NowPlayingData> _processPlaylistInIsolate(List<PlaylistTrack> tracks) {
  // Procesar los tracks en el isolate
  return tracks
      .where(
        (track) =>
            track.videoId != null &&
            track.videoId!.isNotEmpty &&
            track.isAvailable,
      )
      .map(NowPlayingData.fromPlaylistTrack)
      .toList();
}
