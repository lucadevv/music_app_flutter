import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/core/utils/failures/failure.dart';

/// SOLID: Mixin Pattern + Single Responsibility Principle (SRP)
///
/// Este mixin proporciona funcionalidad común para todos los blocs.
/// Centraliza la lógica de manejo de errores para evitar duplicación.
///
/// Patrón aplicado: Mixin Pattern (Composition over Inheritance)
///
/// Uso:
/// ```dart
/// class MyBloc extends Bloc<MyEvent, MyState> with BaseBlocMixin {
///   // Ahora puedes usar getErrorMessage(exception)
/// }
/// ```
mixin BaseBlocMixin {
  /// Obtiene el mensaje de error desde una excepción
  ///
  /// Centraliza la lógica de extracción de mensajes de error,
  /// permitiendo personalizar el mensaje según el tipo de excepción
  /// en el futuro sin modificar todos los blocs.
  String getErrorMessage(dynamic error) {
    if (error is AppException) return error.message;
    if (error is Failure) return error.message;
    return error.toString();
  }
}
