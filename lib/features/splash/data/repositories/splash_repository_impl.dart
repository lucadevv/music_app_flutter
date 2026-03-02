import 'package:dartz/dartz.dart';
import 'package:music_app/features/splash/data/datasources/splash_data_source.dart';
import 'package:music_app/features/splash/domain/entities/splash_entity.dart';
import 'package:music_app/features/splash/domain/repositories/splash_repository.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

/// Implementation of SplashRepository.
class SplashRepositoryImpl implements SplashRepository {
  final SplashDataSource _dataSource;

  SplashRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, SplashEntity>> initializeApp() async {
    try {
      final result = await _dataSource.initializeApp();
      return Right(result);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
