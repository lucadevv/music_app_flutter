import 'package:get_it/get_it.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:music_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:music_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_app/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:music_app/features/profile/domain/use_cases/get_settings_use_case.dart';
import 'package:music_app/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:music_app/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:music_app/features/profile/domain/use_cases/update_settings_use_case.dart';

Future<void> registerProfileFeature(GetIt getIt) async {
  // Data layer
  if (!getIt.isRegistered<ProfileRemoteDataSource>()) {
    getIt.registerLazySingleton<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSource(getIt<ApiServices>(), getIt<AuthManager>()),
    );
  }

  if (!getIt.isRegistered<ProfileRepository>()) {
    getIt.registerLazySingleton<ProfileRepository>(
      () => ProfileRepositoryImpl(getIt<ProfileRemoteDataSource>()),
    );
  }

  // Use cases
  if (!getIt.isRegistered<GetProfileUseCase>()) {
    getIt.registerFactory<GetProfileUseCase>(
      () => GetProfileUseCase(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<UpdateProfileUseCase>()) {
    getIt.registerFactory<UpdateProfileUseCase>(
      () => UpdateProfileUseCase(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<GetSettingsUseCase>()) {
    getIt.registerFactory<GetSettingsUseCase>(
      () => GetSettingsUseCase(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<UpdateSettingsUseCase>()) {
    getIt.registerFactory<UpdateSettingsUseCase>(
      () => UpdateSettingsUseCase(getIt<ProfileRepository>()),
    );
  }

  if (!getIt.isRegistered<LogoutUseCase>()) {
    getIt.registerFactory<LogoutUseCase>(
      () => LogoutUseCase(getIt<ProfileRepository>()),
    );
  }

  // ProfileCubit now created directly in app.dart, NO longer registered here
}
