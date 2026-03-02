import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/splash/domain/entities/splash_entity.dart';

/// Repository interface for splash/initialization operations.
abstract class SplashRepository {
  /// Initialize app and get redirect route
  Future<Either<AppException, SplashEntity>> initializeApp();
}
