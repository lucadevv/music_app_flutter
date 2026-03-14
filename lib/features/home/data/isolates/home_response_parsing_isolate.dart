import 'package:flutter/foundation.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/home/data/models/home_response_model.dart';

/// Clase responsable del parseo aislado de la respuesta de Home (Multi-threading)
/// 
/// Esto previene UI Jank durante la decodificación de objetos JSON de gran peso.
class HomeResponseParsingIsolate {
  /// Procesa la respuesta JSON del servidor y la transforma en un [HomeResponseModel].
  /// Utiliza `compute` para realizar la carga pesada en un Isolate independiente.
  static Future<HomeResponseModel> parseResponse(dynamic json) async {
    return compute(_parseHomeResponseInIsolate, json);
  }
}

/// Función top-level requerida para poder usarse con `compute`.
/// Parsea crúdamente el JSON a Entidad Model.
HomeResponseModel _parseHomeResponseInIsolate(dynamic json) {
  if (json is! Map<String, dynamic>) {
    throw const ServerException('El formato de respuesta no es un Mapa válido');
  }

  try {
    return HomeResponseModel.fromJson(json);
  } catch (e, stack) {
    throw ServerException('Falla decodificando el Home Response: $e\\n$stack');
  }
}
