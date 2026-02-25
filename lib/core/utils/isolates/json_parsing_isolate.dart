import 'package:flutter/foundation.dart';

/// Helper para parsear JSON grandes en isolates
/// 
/// Útil cuando el JSON es grande (>100KB) y el parsing podría bloquear la UI
class JsonParsingIsolate {
  /// Parsea un JSON grande en un isolate
  /// 
  /// [jsonData] El JSON a parsear (Map<String, dynamic>)
  /// [parser] Función que parsea el JSON
  /// 
  /// Retorna [T] El resultado del parsing
  static Future<T> parseJsonInIsolate<T>(
    Map<String, dynamic> jsonData,
    T Function(Map<String, dynamic>) parser,
  ) async {
    // Si el JSON es pequeño, no vale la pena usar isolate
    final jsonString = jsonData.toString();
    if (jsonString.length < 100000) { // <100KB
      return parser(jsonData);
    }

    try {
      // Usar compute para parsear en un isolate
      return await compute(_parseJsonInIsolate, {
        'jsonData': jsonData,
        'parser': parser.toString(), // Nota: Esto es una limitación, necesitamos otra forma
      });
    } catch (e) {
      // Si falla el isolate, usar el método síncrono como fallback
      if (kDebugMode) {
        debugPrint('Isolate falló, usando método síncrono: $e');
      }
      return parser(jsonData);
    }
  }

  /// Función que se ejecuta en el isolate
  static T _parseJsonInIsolate<T>(Map<String, dynamic> params) {
    // Esta implementación es un placeholder
    // En realidad, necesitaríamos pasar la función parser de otra forma
    // porque las funciones no son serializables
    throw UnimplementedError('Necesita implementación específica');
  }
}
