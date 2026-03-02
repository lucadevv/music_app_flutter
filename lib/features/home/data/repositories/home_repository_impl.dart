import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../../domain/entities/home_response.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_sources/home_remote_data_source.dart';

/// Implementación del repositorio del home
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Coordinar entre data source y domain
class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource _remoteDataSource;

  HomeRepositoryImpl(this._remoteDataSource);

  @override
  Future<Either<AppException, HomeResponse>> getHome() async {
    return _remoteDataSource.getHome();
  }
}
