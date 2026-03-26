import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:music_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:music_app/features/auth/data/services/oauth_service.dart';
import 'package:music_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:music_app/features/auth/domain/use_cases/login_use_case.dart';
import 'package:music_app/features/auth/domain/use_cases/oauth_sign_in_use_case.dart';
import 'package:music_app/features/auth/domain/use_cases/refresh_token_use_case.dart';
import 'package:music_app/features/auth/domain/use_cases/register_use_case.dart';

void registerAuthFeature(GetIt getIt) {
  // Data Sources
  if (!getIt.isRegistered<AuthRemoteDataSource>()) {
    getIt.registerLazySingleton<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(getIt<ApiServices>()),
    );
  }

  // OAuth Service
  if (!getIt.isRegistered<OAuthService>()) {
    getIt.registerLazySingleton<OAuthService>(OAuthServiceImpl.new);
  }

  // Repositories
  if (!getIt.isRegistered<AuthRepository>()) {
    getIt.registerLazySingleton<AuthRepository>(
      () => AuthRepositoryImpl(getIt<AuthRemoteDataSource>()),
    );
  }

  // Use Cases
  if (!getIt.isRegistered<RegisterUseCase>()) {
    getIt.registerLazySingleton<RegisterUseCase>(
      () => RegisterUseCase(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<LoginUseCase>()) {
    getIt.registerLazySingleton<LoginUseCase>(
      () => LoginUseCase(getIt<AuthRepository>()),
    );
  }

  if (!getIt.isRegistered<RefreshTokenUseCase>()) {
    getIt.registerLazySingleton<RefreshTokenUseCase>(
      () => RefreshTokenUseCase(getIt<AuthRepository>()),
    );
  }

  // OAuth Use Cases
  if (!getIt.isRegistered<GoogleSignInUseCase>()) {
    getIt.registerLazySingleton<GoogleSignInUseCase>(
      () => GoogleSignInUseCase(getIt<AuthRepository>(), getIt<OAuthService>()),
    );
  }

  if (!getIt.isRegistered<AppleSignInUseCase>()) {
    getIt.registerLazySingleton<AppleSignInUseCase>(
      () => AppleSignInUseCase(getIt<AuthRepository>(), getIt<OAuthService>()),
    );
  }

  // Cubits now created directly in screens with BlocProvider
}
