import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/app_router/app_routes.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/managers/auth/auth_manager_impl.dart';
import 'package:music_app/core/managers/auth/storage/token_manager.dart';
import 'package:music_app/core/services/auth/auth_service.dart';
import 'package:music_app/core/services/local/local_storage_service.dart';
import 'package:music_app/core/services/local/onboarding_service.dart';
import 'package:music_app/core/services/local/shared_preferences_service_impl.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/services/network/dio_services_impl.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/album/data/repositories/album_repository_impl.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';
import 'package:music_app/features/artist/data/repositories/artist_repository_impl.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';
import 'package:music_app/features/auth/data/services/oauth_service.dart';
import 'package:music_app/features/auth/login/domain/use_cases/login_use_case.dart';
import 'package:music_app/features/auth/login/domain/use_cases/oauth_sign_in_use_case.dart';
import 'package:music_app/features/auth/refresh_token/domain/use_cases/refresh_token_use_case.dart';
import 'package:music_app/features/auth/register/data/data_sources/auth_remote_data_source.dart';
import 'package:music_app/features/auth/register/data/repositories/auth_repository_impl.dart';
import 'package:music_app/features/auth/register/domain/repositories/auth_repository.dart';
import 'package:music_app/features/auth/register/domain/use_cases/register_use_case.dart';
import 'package:music_app/features/downloads/data/data_sources/downloads_local_data_source.dart';
import 'package:music_app/features/downloads/data/repositories/downloads_repository_impl.dart';
import 'package:music_app/features/downloads/domain/repositories/downloads_repository.dart';
import 'package:music_app/features/downloads/domain/use_cases/check_download_status_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/download_song_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/get_downloaded_songs_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/remove_download_use_case.dart';
import 'package:music_app/features/home/data/data_sources/home_remote_data_source.dart';
import 'package:music_app/features/home/data/repositories/home_repository_impl.dart';
import 'package:music_app/features/home/domain/repositories/home_repository.dart';
import 'package:music_app/features/home/domain/use_cases/get_home_use_case.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/mood_genre/data/data_sources/mood_genre_remote_data_source.dart';
import 'package:music_app/features/mood_genre/data/repositories/mood_genre_repository_impl.dart';
import 'package:music_app/features/mood_genre/domain/repositories/mood_genre_repository.dart';
import 'package:music_app/features/mood_genre/domain/use_cases/get_mood_playlists_use_case.dart';
import 'package:music_app/features/player/data/datasources/radio_remote_data_source.dart';
import 'package:music_app/features/player/data/repositories/player_repository_impl.dart';
import 'package:music_app/features/player/data/repositories/radio_repository_impl.dart';
import 'package:music_app/features/player/domain/repositories/player_repository.dart';
import 'package:music_app/features/player/domain/repositories/radio_repository.dart';
import 'package:music_app/features/player/domain/usecases/get_history_use_case.dart';
import 'package:music_app/features/player/domain/usecases/get_similar_songs_use_case.dart';
import 'package:music_app/features/player/domain/usecases/get_radio_playlist_usecase.dart';
import 'package:music_app/features/player/domain/usecases/manage_history_use_case.dart';
import 'package:music_app/features/playlist/data/data_sources/playlist_remote_data_source.dart';
import 'package:music_app/features/playlist/data/repositories/playlist_repository_impl.dart';
import 'package:music_app/features/playlist/domain/repositories/playlist_repository.dart';
import 'package:music_app/features/playlist/domain/use_cases/get_playlist_use_case.dart';
import 'package:music_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:music_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:music_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:music_app/features/profile/domain/use_cases/get_profile_use_case.dart';
import 'package:music_app/features/profile/domain/use_cases/get_settings_use_case.dart';
import 'package:music_app/features/profile/domain/use_cases/logout_use_case.dart';
import 'package:music_app/features/profile/domain/use_cases/update_profile_use_case.dart';
import 'package:music_app/features/profile/domain/use_cases/update_settings_use_case.dart';
import 'package:music_app/features/recently_played/data/datasources/recently_played_remote_data_source.dart';
import 'package:music_app/features/recently_played/data/repositories/recently_played_repository_impl.dart';
import 'package:music_app/features/recently_played/domain/repositories/recently_played_repository.dart';
import 'package:music_app/features/recently_played/domain/usecases/get_recently_played_usecase.dart';
import 'package:music_app/features/recently_played/domain/usecases/record_listen_usecase.dart';
import 'package:music_app/features/search/data/data_sources/search_remote_data_source.dart';
import 'package:music_app/features/search/data/repositories/search_repository_impl.dart';
import 'package:music_app/features/search/domain/repositories/search_repository.dart';
import 'package:music_app/features/search/domain/use_cases/get_categories_usecase.dart';
import 'package:music_app/features/search/domain/use_cases/get_recent_searches_use_case.dart';
import 'package:music_app/features/search/domain/use_cases/search_use_case.dart';
import 'package:music_app/features/search/domain/use_cases/update_selected_song_use_case.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppInjection {
  final GetIt _getIt;
  final String _baseUrl;
  bool _isInitialized = false;

  AppInjection({required GetIt getIt, required String baseUrl})
    : _getIt = getIt,
      _baseUrl = baseUrl {
    // Don't call _init() here - call init() explicitly from main.dart
  }

  /// Initialize all dependencies asynchronously
  /// Must be called after construction and BEFORE allReady()
  Future<void> init() async {
    if (_isInitialized) {
      return;
    }

    await _registerCoreDependencies();
    await _registerAuthManager();
    await _registerFeatures();
    _isInitialized = true;
  }

  /// Register core synchronous dependencies
  Future<void> _registerCoreDependencies() async {
    if (!_getIt.isRegistered<AppRouter>()) {
      _getIt.registerLazySingleton<AppRouter>(AppRouter.new);
    }

    if (!_getIt.isRegistered<ApiServices>()) {
      _getIt.registerLazySingleton<ApiServices>(
        () => DioApiServicesImpl(_baseUrl),
      );
    }

    if (!_getIt.isRegistered<LocalStorageService>()) {
      _getIt.registerLazySingleton<LocalStorageService>(
        SharedPreferencesServiceImpl.new,
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
        SharedPreferences.getInstance,
      );
    }

    // Dio for downloads
    if (!_getIt.isRegistered<Dio>()) {
      _getIt.registerLazySingleton<Dio>(Dio.new);
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
  }

  /// Register AuthManager and wait for it to be ready
  /// This is CRITICAL - ProfileCubit depends on AuthManager
  Future<void> _registerAuthManager() async {
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

    // OnboardingService - lazy singleton async porque depende de SharedPreferences
    if (!_getIt.isRegistered<OnboardingService>()) {
      _getIt.registerLazySingletonAsync<OnboardingService>(
        () async =>
            OnboardingService(await _getIt.getAsync<SharedPreferences>()),
      );
    }

    // LibraryService - singleton para manejar la biblioteca del usuario
    if (!_getIt.isRegistered<LibraryService>()) {
      _getIt.registerLazySingleton<LibraryService>(
        () => LibraryService(_getIt<ApiServices>()),
      );
    }
  }

  /// Register all feature dependencies
  /// Note: _registerProfileFeature is async and must be awaited
  Future<void> _registerFeatures() async {
    _registerAuthFeature();
    _registerSearchFeature();
    _registerPlayerFeature();
    _registerHomeFeature();
    _registerMoodGenreFeature();
    _registerPlaylistFeature();
    // CRITICAL: OfflineFeature must be registered BEFORE DownloadsFeature
    // because DownloadsLocalDataSource depends on OfflineService
    _registerOfflineFeature();
    _registerDownloadsFeature();
    _registerLibraryFeature();
    _registerArtistFeature();
    _registerAlbumFeature();
    _registerFavoritesFeature();
    _registerRecentlyPlayedFeature();
    // CRITICAL: This must be awaited - ProfileCubit depends on AuthManager being ready
    await _registerProfileFeature();
  }

  void _registerAuthFeature() {
    // Data Sources
    if (!_getIt.isRegistered<AuthRemoteDataSource>()) {
      _getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(_getIt<ApiServices>()),
      );
    }

    // OAuth Service
    if (!_getIt.isRegistered<OAuthService>()) {
      _getIt.registerLazySingleton<OAuthService>(OAuthServiceImpl.new);
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

    // OAuth Use Cases
    if (!_getIt.isRegistered<GoogleSignInUseCase>()) {
      _getIt.registerLazySingleton<GoogleSignInUseCase>(
        () => GoogleSignInUseCase(
          _getIt<AuthRepository>(),
          _getIt<OAuthService>(),
        ),
      );
    }

    if (!_getIt.isRegistered<AppleSignInUseCase>()) {
      _getIt.registerLazySingleton<AppleSignInUseCase>(
        () => AppleSignInUseCase(
          _getIt<AuthRepository>(),
          _getIt<OAuthService>(),
        ),
      );
    }

    // Cubits now created directly in screens with BlocProvider
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

    if (!_getIt.isRegistered<GetCategoriesUseCase>()) {
      _getIt.registerLazySingleton<GetCategoriesUseCase>(
        () => GetCategoriesUseCase(_getIt<SearchRemoteDataSource>()),
      );
    }

    if (!_getIt.isRegistered<UpdateSelectedSongUseCase>()) {
      _getIt.registerLazySingleton<UpdateSelectedSongUseCase>(
        () => UpdateSelectedSongUseCase(_getIt<SearchRepository>()),
      );
    }

    // Cubits now created directly in screens with BlocProvider
  }

  void _registerPlayerFeature() {
    // Data Sources
    if (!_getIt.isRegistered<RadioRemoteDataSource>()) {
      _getIt.registerLazySingleton<RadioRemoteDataSource>(
        () => RadioRemoteDataSourceImpl(_getIt<ApiServices>()),
      );
    }

    // Repositories
    if (!_getIt.isRegistered<RadioRepository>()) {
      _getIt.registerLazySingleton<RadioRepository>(
        () => RadioRepositoryImpl(_getIt<RadioRemoteDataSource>()),
      );
    }

    // Use Cases
    if (!_getIt.isRegistered<GetRadioPlaylistUseCase>()) {
      _getIt.registerLazySingleton<GetRadioPlaylistUseCase>(
        () => GetRadioPlaylistUseCase(_getIt<RadioRepository>()),
      );
    }

    // PlayerRepository - singleton async (needs OfflineService which is async)
    if (!_getIt.isRegistered<PlayerRepository>()) {
      _getIt.registerLazySingletonAsync<PlayerRepository>(
        () async => PlayerRepositoryImpl(
          offlineService: await _getIt.getAsync<OfflineService>(),
          recordListenUseCase: _getIt<RecordListenUseCase>(),
        ),
      );
    }

    // Player Use Cases - factory (new instance each time for stateful use cases)
    if (!_getIt.isRegistered<ManageHistoryUseCase>()) {
      _getIt.registerFactory<ManageHistoryUseCase>(
        () => ManageHistoryUseCase(_getIt<PlayerRepository>()),
      );
    }

    if (!_getIt.isRegistered<GetHistoryUseCase>()) {
      _getIt.registerFactory<GetHistoryUseCase>(
        () => GetHistoryUseCase(_getIt<PlayerRepository>()),
      );
    }

    if (!_getIt.isRegistered<GetSimilarSongsUseCase>()) {
      _getIt.registerFactory<GetSimilarSongsUseCase>(
        () => GetSimilarSongsUseCase(_getIt<PlayerRepository>()),
      );
    }

    // PlayerBlocBloc now created directly in app.dart, NO longer registered here
    // PlayerFacade usa el PlayerBlocBloc de app.dart, NO crea uno nuevo
    // NOTA: PlayerFacade se registra en app.dart después de crear PlayerBlocBloc
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

    // NOTA: HomeCubit se crea ahora vía BlocProvider en HomeShell.wrappedRoute
    // Se elimina el registro de GetIt para mantener consistencia con el patrón
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

    // NOTA: MoodGenreCubit se crea ahora vía BlocProvider en MoodGenreScreen.wrappedRoute
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

    // PlaylistCubit se crea directamente en PlaylistScreen con BlocProvider
    // No se registra aquí porque necesita PlayerBloc que es un singleton
  }

  void _registerDownloadsFeature() {
    // Data Sources - singleton because needs to share state with OfflineService
    if (!_getIt.isRegistered<DownloadsLocalDataSource>()) {
      _getIt.registerLazySingletonAsync<DownloadsLocalDataSource>(() async {
        final dataSource = DownloadsLocalDataSourceImpl(
          await _getIt.getAsync<OfflineService>(),
        );
        await dataSource.init();
        return dataSource;
      });
    }

    // Repository - singleton to share state
    if (!_getIt.isRegistered<DownloadsRepository>()) {
      _getIt.registerLazySingletonAsync<DownloadsRepository>(
        () async => DownloadsRepositoryImpl(
          await _getIt.getAsync<DownloadsLocalDataSource>(),
        ),
      );
    }

    // Use Cases - factory async because they depend on repository async
    if (!_getIt.isRegistered<DownloadSongUseCase>()) {
      _getIt.registerFactoryAsync<DownloadSongUseCase>(
        () async =>
            DownloadSongUseCase(await _getIt.getAsync<DownloadsRepository>()),
      );
    }

    if (!_getIt.isRegistered<GetDownloadedSongsUseCase>()) {
      _getIt.registerFactoryAsync<GetDownloadedSongsUseCase>(
        () async => GetDownloadedSongsUseCase(
          await _getIt.getAsync<DownloadsRepository>(),
        ),
      );
    }

    if (!_getIt.isRegistered<RemoveDownloadUseCase>()) {
      _getIt.registerFactoryAsync<RemoveDownloadUseCase>(
        () async =>
            RemoveDownloadUseCase(await _getIt.getAsync<DownloadsRepository>()),
      );
    }

    if (!_getIt.isRegistered<CheckDownloadStatusUseCase>()) {
      _getIt.registerFactoryAsync<CheckDownloadStatusUseCase>(
        () async => CheckDownloadStatusUseCase(
          await _getIt.getAsync<DownloadsRepository>(),
        ),
      );
    }

    // DownloadsCubit now created directly in app.dart, NO longer registered here
  }

  void _registerLibraryFeature() {
    // NOTA: LibraryCubit se crea ahora vía BlocProvider en LibraryScreen
    // Se elimina el registro de GetIt para mantener consistencia
  }

  void _registerArtistFeature() {
    // ArtistRepository
    if (!_getIt.isRegistered<ArtistRepository>()) {
      _getIt.registerLazySingleton<ArtistRepository>(
        () => ArtistRepositoryImpl(_getIt<ApiServices>()),
      );
    }

    // NOTA: ArtistCubit se crea ahora vía BlocProvider en ArtistScreen
  }

  void _registerAlbumFeature() {
    // AlbumRepository
    if (!_getIt.isRegistered<AlbumRepository>()) {
      _getIt.registerLazySingleton<AlbumRepository>(
        () => AlbumRepositoryImpl(_getIt<ApiServices>()),
      );
    }

    // NOTA: AlbumCubit se crea ahora vía BlocProvider en AlbumScreen
  }

  void _registerFavoritesFeature() {
    // FavoriteCubit now created directly in app.dart, NO longer registered here
  }

  void _registerRecentlyPlayedFeature() {
    // Data Source
    if (!_getIt.isRegistered<RecentlyPlayedRemoteDataSource>()) {
      _getIt.registerLazySingleton<RecentlyPlayedRemoteDataSource>(
        () => RecentlyPlayedRemoteDataSourceImpl(_getIt<ApiServices>()),
      );
    }

    // Repository
    if (!_getIt.isRegistered<RecentlyPlayedRepository>()) {
      _getIt.registerLazySingleton<RecentlyPlayedRepository>(
        () => RecentlyPlayedRepositoryImpl(
          _getIt<RecentlyPlayedRemoteDataSource>(),
        ),
      );
    }

    // Use Case
    if (!_getIt.isRegistered<GetRecentlyPlayedUseCase>()) {
      _getIt.registerLazySingleton<GetRecentlyPlayedUseCase>(
        () => GetRecentlyPlayedUseCase(_getIt<RecentlyPlayedRepository>()),
      );
    }

    // Record Listen Use Case
    if (!_getIt.isRegistered<RecordListenUseCase>()) {
      _getIt.registerLazySingleton<RecordListenUseCase>(
        () => RecordListenUseCase(_getIt<RecentlyPlayedRepository>()),
      );
    }
  }

  /// Register ProfileFeature - MUST wait for AuthManager to be ready
  /// Clean Architecture structure with domain, data, and presentation layers
  Future<void> _registerProfileFeature() async {
    // Data layer
    if (!_getIt.isRegistered<ProfileRemoteDataSource>()) {
      _getIt.registerLazySingleton<ProfileRemoteDataSource>(
        () => ProfileRemoteDataSource(
          _getIt<ApiServices>(),
          _getIt<AuthManager>(),
        ),
      );
    }

    if (!_getIt.isRegistered<ProfileRepository>()) {
      _getIt.registerLazySingleton<ProfileRepository>(
        () => ProfileRepositoryImpl(_getIt<ProfileRemoteDataSource>()),
      );
    }

    // Use cases
    if (!_getIt.isRegistered<GetProfileUseCase>()) {
      _getIt.registerFactory<GetProfileUseCase>(
        () => GetProfileUseCase(_getIt<ProfileRepository>()),
      );
    }

    if (!_getIt.isRegistered<UpdateProfileUseCase>()) {
      _getIt.registerFactory<UpdateProfileUseCase>(
        () => UpdateProfileUseCase(_getIt<ProfileRepository>()),
      );
    }

    if (!_getIt.isRegistered<GetSettingsUseCase>()) {
      _getIt.registerFactory<GetSettingsUseCase>(
        () => GetSettingsUseCase(_getIt<ProfileRepository>()),
      );
    }

    if (!_getIt.isRegistered<UpdateSettingsUseCase>()) {
      _getIt.registerFactory<UpdateSettingsUseCase>(
        () => UpdateSettingsUseCase(_getIt<ProfileRepository>()),
      );
    }

    if (!_getIt.isRegistered<LogoutUseCase>()) {
      _getIt.registerFactory<LogoutUseCase>(
        () => LogoutUseCase(_getIt<ProfileRepository>()),
      );
    }

    // ProfileCubit now created directly in app.dart, NO longer registered here
  }

  void _registerOfflineFeature() {
    // Connectivity - singleton to verify connection status
    if (!_getIt.isRegistered<Connectivity>()) {
      _getIt.registerLazySingleton<Connectivity>(Connectivity.new);
    }

    // OfflineService - singleton async because needs initialization with init()
    if (!_getIt.isRegistered<OfflineService>()) {
      _getIt.registerLazySingletonAsync<OfflineService>(() async {
        final service = OfflineService(_getIt<Dio>(), _getIt<Connectivity>());
        await service.init();
        return service;
      });
    }

    // PlaylistOfflineCubit now created directly in app.dart, NO longer registered here
    // HistoryCubit now created directly in app.dart, NO longer registered here
  }
}
