import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/home_response.dart';

/// Repositorio abstracto para operaciones del home
///
/// SOLID: Dependency Inversion Principle (DIP)
/// Define el contrato sin depender de implementaciones concretas
abstract class HomeRepository {
  /// Obtiene los datos del home
  Future<Either<AppException, HomeResponse>> getHome();
}
