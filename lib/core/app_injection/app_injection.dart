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
import 'package:music_app/features/album/album_injection.dart';
import 'package:music_app/features/artist/artist_injection.dart';
import 'package:music_app/features/auth/auth_injection.dart';
import 'package:music_app/features/downloads/downloads_injection.dart';
import 'package:music_app/features/favorites/favorites_injection.dart';
import 'package:music_app/features/home/home_injection.dart';
import 'package:music_app/features/library/library_injection.dart';
import 'package:music_app/features/liked/liked_injection.dart';
import 'package:music_app/features/mood_genre/mood_genre_injection.dart';
import 'package:music_app/features/offline/offline_injection.dart';
import 'package:music_app/features/onboarding/onboarding_injection.dart';
import 'package:music_app/features/player/player_injection.dart';
import 'package:music_app/features/playlist/playlist_injection.dart';
import 'package:music_app/features/profile/profile_injection.dart';
import 'package:music_app/features/recently_played/recently_played_injection.dart';
import 'package:music_app/features/search/search_injection.dart';
import 'package:music_app/features/song_options/song_options_injection.dart';
import 'package:music_app/features/user_playlists/user_playlists_injection.dart';
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
  }

  /// Register all feature dependencies
  /// Note: _registerProfileFeature is async and must be awaited
  Future<void> _registerFeatures() async {
    registerAuthFeature(_getIt);
    registerSearchFeature(_getIt);
    registerPlayerFeature(_getIt);
    registerHomeFeature(_getIt);
    registerMoodGenreFeature(_getIt);
    registerOnboardingFeature(_getIt);
    registerPlaylistFeature(_getIt);
    // CRITICAL: OfflineFeature must be registered BEFORE DownloadsFeature
    // because DownloadsLocalDataSource depends on OfflineService
    registerOfflineFeature(_getIt);
    registerDownloadsFeature(_getIt);
    registerLibraryFeature(_getIt);
    registerLikedFeature(_getIt);
    registerArtistFeature(_getIt);
    registerAlbumFeature(_getIt);
    registerFavoritesFeature(_getIt);
    registerRecentlyPlayedFeature(_getIt);
    registerUserPlaylistsFeature(_getIt);
    registerSongOptionsFeature(_getIt);
    // CRITICAL: This must be awaited - ProfileCubit depends on AuthManager being ready
    await registerProfileFeature(_getIt);
  }

  /// Register ProfileFeature - MUST wait for AuthManager to be ready
  /// Clean Architecture structure with domain, data, and presentation layers
}
