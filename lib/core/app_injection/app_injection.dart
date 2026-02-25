import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/app_router/app_routes.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/managers/auth/auth_manager_impl.dart';
import 'package:music_app/core/managers/auth/storage/token_manager.dart';
import 'package:music_app/core/services/auth/auth_service.dart';
import 'package:music_app/core/services/local/local_storage_service.dart';
import 'package:music_app/core/services/local/shared_preferences_service_impl.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/services/network/dio_services_impl.dart';
import 'package:music_app/features/auth/register/data/data_sources/auth_remote_data_source.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
import 'package:music_app/features/auth/register/data/repositories/auth_repository_impl.dart';
import 'package:music_app/features/auth/register/domain/repositories/auth_repository.dart';
import 'package:music_app/features/auth/register/domain/use_cases/register_use_case.dart';
import 'package:music_app/features/auth/register/presentation/cubit/register_cubit.dart';
import 'package:music_app/features/auth/login/domain/use_cases/login_use_case.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:music_app/features/auth/refresh_token/domain/use_cases/refresh_token_use_case.dart';
import 'package:music_app/features/search/data/data_sources/search_remote_data_source.dart';
import 'package:music_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:music_app/features/search/domain/repositories/search_repository.dart';
import 'package:music_app/features/search/domain/use_cases/search_use_case.dart';
import 'package:music_app/features/search/domain/use_cases/get_recent_searches_use_case.dart';
import 'package:music_app/features/search/presentation/cubit/search_cubit.dart';
import 'package:music_app/features/search/presentation/cubit/recent_searches_cubit.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:music_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:music_app/features/home/domain/repositories/home_repository.dart';
import 'package:music_app/features/home/domain/use_cases/get_home_use_case.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:music_app/features/mood_genre/data/data_sources/mood_genre_remote_data_source.dart';
import 'package:music_app/features/mood_genre/data/repositories/mood_genre_repository_impl.dart';
import 'package:music_app/features/mood_genre/domain/repositories/mood_genre_repository.dart';
import 'package:music_app/features/mood_genre/domain/use_cases/get_mood_playlists_use_case.dart';
import 'package:music_app/features/mood_genre/presentation/cubit/mood_genre_cubit.dart';
import 'package:music_app/features/playlist/data/data_sources/playlist_remote_data_source.dart';
import 'package:music_app/features/playlist/data/repositories/playlist_repository_impl.dart';
import 'package:music_app/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:music_app/features/playlist/domain/use_cases/get_playlist_use_case.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInjection {
  final GetIt _getIt;
  final String _baseUrl;
  final String _accessToken;

  AppInjection({
    required GetIt getIt,
    required String baseUrl,
    required String accessToken,
  }) : _getIt = getIt,
       _baseUrl = baseUrl,
       _accessToken = accessToken {
    _init();
  }

  void _init() {
    if (!_getIt.isRegistered<AppRouter>()) {
      _getIt.registerLazySingleton<AppRouter>(() => AppRouter());
    }

    if (!_getIt.isRegistered<ApiServices>()) {
      _getIt.registerLazySingleton<ApiServices>(
        () => DioApiServicesImpl(_baseUrl, accessToken: _accessToken),
      );
    }

    if (!_getIt.isRegistered<LocalStorageService>()) {
      _getIt.registerLazySingleton<LocalStorageService>(
        () => SharedPreferencesServiceImpl(),
      );
    }

    // FlutterSecureStorage
    if (!_getIt.isRegistered<FlutterSecureStorage>()) {
      _getIt.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(),
      );
    }

    // SharedPreferences - async
    if (!_getIt.isRegistered<Future<SharedPreferences>>()) {
      _getIt.registerSingletonAsync<SharedPreferences>(
        () => SharedPreferences.getInstance(),
      );
    }

    // TokenManager - lazy pero espera SharedPreferences cuando se use
    if (!_getIt.isRegistered<TokenManager>()) {
      _getIt.registerLazySingletonAsync<TokenManager>(
        () async => TokenManager(
          secureStorage: _getIt<FlutterSecureStorage>(),
          prefs: await _getIt.getAsync<SharedPreferences>(),
        ),
      );
    }

    // AuthManager - lazy pero espera TokenManager cuando se use
    if (!_getIt.isRegistered<AuthManager>()) {
      _getIt.registerLazySingletonAsync<AuthManager>(
        () async => AuthManagerImpl(await _getIt.getAsync<TokenManager>()),
      );
    }

    if (!_getIt.isRegistered<AuthService>()) {
      _getIt.registerLazySingleton<AuthService>(
        () => AuthService(_getIt<LocalStorageService>()),
      );
    }

    _registerAuthFeature();
    _registerSearchFeature();
    _registerPlayerFeature();
    _registerHomeFeature();
    _registerMoodGenreFeature();
    _registerPlaylistFeature();
  }

  void _registerAuthFeature() {
    // Data Sources
    if (!_getIt.isRegistered<AuthRemoteDataSource>()) {
      _getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(_getIt<ApiServices>()),
      );
    }

    // Repositories
    if (!_getIt.isRegistered<AuthRepository>()) {
      _getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(_getIt<AuthRemoteDataSource>()),
      );
    }

    // Use Cases
    if (!_getIt.isRegistered<RegisterUseCase>()) {
      _getIt.registerLazySingleton<RegisterUseCase>(
        () => RegisterUseCase(_getIt<AuthRepository>()),
      );
    }

    if (!_getIt.isRegistered<LoginUseCase>()) {
      _getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(_getIt<AuthRepository>()),
      );
    }

    if (!_getIt.isRegistered<RefreshTokenUseCase>()) {
      _getIt.registerLazySingleton<RefreshTokenUseCase>(
        () => RefreshTokenUseCase(_getIt<AuthRepository>()),
      );
    }

    // Cubits (factory porque cada pantalla necesita su propia instancia)
    if (!_getIt.isRegistered<RegisterCubit>()) {
      _getIt.registerFactory<RegisterCubit>(
        () => RegisterCubit(registerUseCase: _getIt<RegisterUseCase>()),
      );
    }

    if (!_getIt.isRegistered<LoginCubit>()) {
      _getIt.registerFactory<LoginCubit>(
        () => LoginCubit(loginUseCase: _getIt<LoginUseCase>()),
      );
    }

    if (!_getIt.isRegistered<OrquestadorAuthCubit>()) {
      _getIt.registerFactory<OrquestadorAuthCubit>(
        () => OrquestadorAuthCubit(),
      );
    }
  }

  void _registerSearchFeature() {
    // Data Sources
    if (!_getIt.isRegistered<SearchRemoteDataSource>()) {
      _getIt.registerLazySingleton<SearchRemoteDataSource>(
        () => SearchRemoteDataSourceImpl(_getIt<ApiServices>()),
      );
    }

    // Repositories
    if (!_getIt.isRegistered<SearchRepository>()) {
      _getIt.registerLazySingleton<SearchRepository>(
        () => SearchRepositoryImpl(_getIt<SearchRemoteDataSource>()),
      );
    }

    // Use Cases
    if (!_getIt.isRegistered<SearchUseCase>()) {
      _getIt.registerLazySingleton<SearchUseCase>(
        () => SearchUseCase(_getIt<SearchRepository>()),
      );
    }

    if (!_getIt.isRegistered<GetRecentSearchesUseCase>()) {
      _getIt.registerLazySingleton<GetRecentSearchesUseCase>(
        () => GetRecentSearchesUseCase(_getIt<SearchRepository>()),
      );
    }

    // Cubits (factory porque cada pantalla necesita su propia instancia)
    if (!_getIt.isRegistered<SearchCubit>()) {
      _getIt.registerFactory<SearchCubit>(
        () => SearchCubit(searchUseCase: _getIt<SearchUseCase>()),
      );
    }

    if (!_getIt.isRegistered<RecentSearchesCubit>()) {
      _getIt.registerFactory<RecentSearchesCubit>(
        () => RecentSearchesCubit(
          getRecentSearchesUseCase: _getIt<GetRecentSearchesUseCase>(),
        ),
      );
    }
  }

  void _registerPlayerFeature() {
    // Bloc (singleton porque debe ser compartido en toda la app)
    if (!_getIt.isRegistered<PlayerBlocBloc>()) {
      _getIt.registerLazySingleton<PlayerBlocBloc>(() => PlayerBlocBloc());
    }
  }

  void _registerHomeFeature() {
    // Data Sources
    if (!_getIt.isRegistered<HomeRemoteDataSource>()) {
      _getIt.registerLazySingleton<HomeRemoteDataSource>(
        () => HomeRemoteDataSourceImpl(_getIt<ApiServices>()),
      );
    }

    // Repositories
    if (!_getIt.isRegistered<HomeRepository>()) {
      _getIt.registerLazySingleton<HomeRepository>(
        () => HomeRepositoryImpl(_getIt<HomeRemoteDataSource>()),
      );
    }

    // Use Cases
    if (!_getIt.isRegistered<GetHomeUseCase>()) {
      _getIt.registerLazySingleton<GetHomeUseCase>(
        () => GetHomeUseCase(_getIt<HomeRepository>()),
      );
    }

    // Cubits (factory porque cada pantalla necesita su propia instancia)
    if (!_getIt.isRegistered<HomeCubit>()) {
      _getIt.registerFactory<HomeCubit>(
        () => HomeCubit(_getIt<GetHomeUseCase>()),
      );
    }

    // OrquestadorHomeCubit se crea en HomeShell con los cubits necesarios
    // No se registra aquí porque necesita los cubits del contexto
  }

  void _registerMoodGenreFeature() {
    // Data Sources
    if (!_getIt.isRegistered<MoodGenreRemoteDataSource>()) {
      _getIt.registerLazySingleton<MoodGenreRemoteDataSource>(
        () => MoodGenreRemoteDataSourceImpl(_getIt<ApiServices>()),
      );
    }

    // Repositories
    if (!_getIt.isRegistered<MoodGenreRepository>()) {
      _getIt.registerLazySingleton<MoodGenreRepository>(
        () => MoodGenreRepositoryImpl(_getIt<MoodGenreRemoteDataSource>()),
      );
    }

    // Use Cases
    if (!_getIt.isRegistered<GetMoodPlaylistsUseCase>()) {
      _getIt.registerLazySingleton<GetMoodPlaylistsUseCase>(
        () => GetMoodPlaylistsUseCase(_getIt<MoodGenreRepository>()),
      );
    }

    // Cubits (factory porque cada pantalla necesita su propia instancia)
    if (!_getIt.isRegistered<MoodGenreCubit>()) {
      _getIt.registerFactory<MoodGenreCubit>(
        () => MoodGenreCubit(_getIt<GetMoodPlaylistsUseCase>()),
      );
    }
  }

  void _registerPlaylistFeature() {
    // Data Sources
    if (!_getIt.isRegistered<PlaylistRemoteDataSource>()) {
      _getIt.registerLazySingleton<PlaylistRemoteDataSource>(
        () => PlaylistRemoteDataSourceImpl(_getIt<ApiServices>()),
      );
    }

    // Repositories
    if (!_getIt.isRegistered<PlaylistRepository>()) {
      _getIt.registerLazySingleton<PlaylistRepository>(
        () => PlaylistRepositoryImpl(_getIt<PlaylistRemoteDataSource>()),
      );
    }

    // Use Cases
    if (!_getIt.isRegistered<GetPlaylistUseCase>()) {
      _getIt.registerLazySingleton<GetPlaylistUseCase>(
        () => GetPlaylistUseCase(_getIt<PlaylistRepository>()),
      );
    }

    // Cubits (factory porque cada pantalla necesita su propia instancia)
    if (!_getIt.isRegistered<PlaylistCubit>()) {
      _getIt.registerFactory<PlaylistCubit>(
        () => PlaylistCubit(getPlaylistUseCase: _getIt<GetPlaylistUseCase>()),
      );
    }
  }
}
