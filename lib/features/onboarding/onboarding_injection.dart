import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/local/onboarding_service.dart';
import 'package:music_app/features/onboarding/data/datasources/onboarding_data_source.dart';
import 'package:music_app/features/onboarding/data/repositories/onboarding_repository_impl.dart';
import 'package:music_app/features/onboarding/domain/repositories/onboarding_repository.dart';
import 'package:music_app/features/onboarding/domain/use_cases/check_onboarding_completed_use_case.dart';
import 'package:music_app/features/onboarding/domain/use_cases/complete_onboarding_use_case.dart';

void registerOnboardingFeature(GetIt getIt) {
  // Data Source - depends on OnboardingService (already registered)
  if (!getIt.isRegistered<OnboardingDataSource>()) {
    getIt.registerLazySingleton<OnboardingDataSource>(
      () => OnboardingDataSource(getIt<OnboardingService>()),
    );
  }

  // Repository
  if (!getIt.isRegistered<OnboardingRepository>()) {
    getIt.registerLazySingleton<OnboardingRepository>(
      () => OnboardingRepositoryImpl(getIt<OnboardingDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<CheckOnboardingCompletedUseCase>()) {
    getIt.registerLazySingleton<CheckOnboardingCompletedUseCase>(
      () => CheckOnboardingCompletedUseCase(getIt<OnboardingRepository>()),
    );
  }

  if (!getIt.isRegistered<CompleteOnboardingUseCase>()) {
    getIt.registerLazySingleton<CompleteOnboardingUseCase>(
      () => CompleteOnboardingUseCase(getIt<OnboardingRepository>()),
    );
  }

  // OnboardingCubit is created via BlocProvider in OnboardingScreen.wrappedRoute
}
