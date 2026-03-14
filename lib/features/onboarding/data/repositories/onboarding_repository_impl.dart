import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:music_app/features/onboarding/domain/entities/onboarding_entity.dart';
import 'package:music_app/features/onboarding/domain/repositories/onboarding_repository.dart';

/// Implementation of OnboardingRepository.
class OnboardingRepositoryImpl implements OnboardingRepository {
  final OnboardingDataSource _dataSource;

  OnboardingRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, bool>> isOnboardingCompleted() async {
    try {
      final result = await _dataSource.isOnboardingCompleted();
      return Right(result);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, void>> setOnboardingCompleted(bool completed) async {
    try {
      await _dataSource.setOnboardingCompleted(completed);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }

  @override
  Future<Either<AppException, List<OnboardingPageEntity>>> getOnboardingPages() async {
    try {
      final pages = await _dataSource.getOnboardingPages();
      return Right(pages);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
