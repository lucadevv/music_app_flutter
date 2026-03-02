import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/splash/domain/entities/splash_entity.dart';
import 'package:music_app/features/splash/domain/repositories/splash_repository.dart';

/// Use case for initializing the app (splash screen).
class InitializeAppUseCase {
  final SplashRepository _repository;

  InitializeAppUseCase(this._repository);

  Future<Either<AppException, SplashEntity>> call() {
    return _repository.initializeApp();
  }
}
