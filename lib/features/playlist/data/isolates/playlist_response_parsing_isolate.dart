import 'package:flutter/foundation.dart';
import '../models/playlist_response_model.dart';

/// Helper para parsear PlaylistResponse grandes en isolates
///
/// Útil cuando una playlist tiene muchos tracks (>100) y el parsing
/// podría bloquear el hilo principal
class PlaylistResponseParsingIsolate {
  /// Parsea un PlaylistResponse en un isolate si es grande
  ///
  /// [json] El JSON a parsear
  ///
  /// Retorna [PlaylistResponseModel]
  static Future<PlaylistResponseModel> parseInIsolate(
    Map<String, dynamic> json,
  ) async {
    // Verificar si la playlist es grande
    final trackCount = (json['tracks'] as List?)?.length ?? 0;
    final jsonSize = json.toString().length;

    // Si la playlist es pequeña o el JSON es pequeño, no usar isolate
    if (trackCount < 100 && jsonSize < 50000) {
      return PlaylistResponseModel.fromJson(json);
    }

    try {
      // Usar compute para parsear en un isolate
      return await compute(_parsePlaylistResponseInIsolate, json);
    } catch (e) {
      // Si falla el isolate, usar el método síncrono como fallback
      if (kDebugMode) {
        debugPrint(
          'PlaylistResponse isolate falló, usando método síncrono: $e',
        );
      }
      return PlaylistResponseModel.fromJson(json);
    }
  }

  /// Función top-level que se ejecuta en el isolate
  static PlaylistResponseModel _parsePlaylistResponseInIsolate(
    Map<String, dynamic> json,
  ) {
    // Esta función se ejecuta en el isolate
    // Llama al método fromJson normal
    return PlaylistResponseModel.fromJson(json);
  }
}
