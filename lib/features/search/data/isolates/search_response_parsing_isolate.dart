import 'package:flutter/foundation.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/search/data/models/search_response_model.dart';

/// Clase responsable del parseo aislado de la respuesta de Search (Multi-threading)
/// 
/// Esto previene UI Jank durante la decodificación de objetos JSON de gran peso
/// (por ejemplo, búsquedas con decenas de resultados ricos en metadata).
class SearchResponseParsingIsolate {
  /// Procesa la respuesta JSON del servidor y la transforma en un [SearchResponseModel].
  /// Utiliza `compute` para realizar la carga pesada en un Isolate independiente.
  static Future<SearchResponseModel> parseResponse(dynamic json) async {
    return compute(_parseSearchResponseInIsolate, json);
  }
}

/// Función top-level requerida para poder usarse con `compute`.
/// Parsea crúdamente el JSON a Entidad Model.
SearchResponseModel _parseSearchResponseInIsolate(dynamic json) {
  if (json is! Map<String, dynamic>) {
    throw const ServerException('El formato de respuesta de búsqueda no es un Mapa válido');
  }

  try {
    return SearchResponseModel.fromJson(json);
  } catch (e, stack) {
    throw ServerException('Falla decodificando el Search Response: $e\\n$stack');
  }
}
