import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/home_response.dart';
import '../repositories/home_repository.dart';

/// Use case para obtener los datos del home
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Orquestar la obtención de datos del home
///
/// Clean Architecture: Capa de dominio - lógica de negocio
class GetHomeUseCase {
  final HomeRepository _repository;

  GetHomeUseCase(this._repository);

  /// Ejecuta el caso de uso para obtener los datos del home
  ///
  /// Retorna [Either<AppException, HomeResponse>]
  Future<Either<AppException, HomeResponse>> call() async {
    return _repository.getHome();
  }
}
