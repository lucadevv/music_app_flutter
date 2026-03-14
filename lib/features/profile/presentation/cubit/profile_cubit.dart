import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:music_app/features/profile/domain/entities/entities.dart';
import 'package:music_app/features/profile/domain/use_cases/use_cases.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> with BaseBlocMixin {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final GetSettingsUseCase _getSettingsUseCase;
  final UpdateSettingsUseCase _updateSettingsUseCase;
  final LogoutUseCase _logoutUseCase;
  final AuthManager _authManager;
  final OfflineService _offlineService;
  final FavoriteCubit _favoriteCubit;

  ProfileCubit({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required GetSettingsUseCase getSettingsUseCase,
    required UpdateSettingsUseCase updateSettingsUseCase,
    required LogoutUseCase logoutUseCase,
    required AuthManager authManager,
    required OfflineService offlineService,
    required FavoriteCubit favoriteCubit,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _getSettingsUseCase = getSettingsUseCase,
        _updateSettingsUseCase = updateSettingsUseCase,
        _logoutUseCase = logoutUseCase,
        _authManager = authManager,
        _offlineService = offlineService,
        _favoriteCubit = favoriteCubit,
        super(const ProfileState());

  Future<void> loadProfile() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _getProfileUseCase();

    result.fold(
      (error) {
        if (isClosed) return;
        emit(state.copyWith(
          isLoading: false,
          errorMessage: getErrorMessage(error),
        ));
      },
      (profile) {
        if (isClosed) return;
        emit(
          state.copyWith(
            isLoading: false,
            profile: profile,
            id: profile.id,
            email: profile.email,
            firstName: profile.firstName,
            lastName: profile.lastName,
            avatarUrl: profile.avatar,
            provider: profile.provider,
            role: profile.role,
            isEmailVerified: profile.isEmailVerified,
            createdAt: profile.createdAt,
          ),
        );
      },
    );
  }

  Future<void> loadSettings() async {
    if (state.isSettingsLoading) return;

    emit(state.copyWith(isSettingsLoading: true, clearSettingsError: true));

    final result = await _getSettingsUseCase();

    result.fold(
      (error) {
        if (isClosed) return;
        emit(state.copyWith(
          isSettingsLoading: false,
          settingsError: getErrorMessage(error),
        ));
      },
      (settings) {
        if (isClosed) return;
        emit(state.copyWith(isSettingsLoading: false, settings: settings));
      },
    );
  }

  Future<void> updateSettings(UserSettingsEntity settings) async {
    if (state.isSettingsLoading) return;

    emit(state.copyWith(isSettingsLoading: true, clearSettingsError: true));

    final result = await _updateSettingsUseCase(settings);

    result.fold(
      (error) {
        if (isClosed) return;
        emit(state.copyWith(
          isSettingsLoading: false,
          settingsError: getErrorMessage(error),
        ));
      },
      (updatedSettings) {
        if (isClosed) return;
        emit(state.copyWith(
          isSettingsLoading: false,
          settings: updatedSettings,
        ));
      },
    );
  }

  Future<void> updateLanguage(String language) async {
    final currentSettings = state.settings ?? const UserSettingsEntity();
    final newSettings = currentSettings.copyWith(language: language);
    await updateSettings(newSettings);
  }

  Future<void> updateStreamingQuality(String quality) async {
    final currentSettings = state.settings ?? const UserSettingsEntity();
    final newSettings = currentSettings.copyWith(streamingQuality: quality);
    await updateSettings(newSettings);
  }

  Future<void> updateDownloadQuality(String quality) async {
    final currentSettings = state.settings ?? const UserSettingsEntity();
    final newSettings = currentSettings.copyWith(downloadQuality: quality);
    await updateSettings(newSettings);
  }

  Future<void> updateEqualizerPreset(String preset) async {
    final currentSettings = state.settings ?? const UserSettingsEntity();
    final newSettings = currentSettings.copyWith(equalizerPreset: preset);
    await updateSettings(newSettings);
  }

  Future<void> loadLibraryStats() async {
    if (state.isLoadingStats) return;

    emit(state.copyWith(isLoadingStats: true));

    try {
      // Obtener canciones descargadas de OfflineService
      final downloadedCount = await _offlineService.getDownloadedSongsCount();
      
      // Obtener favoritos de FavoriteCubit
      final favoriteState = _favoriteCubit.state;
      final songsCount = favoriteState.favoriteSongs.length;
      final playlistsCount = favoriteState.favoritePlaylists.length;

      if (isClosed) return;
      emit(
        state.copyWith(
          isLoadingStats: false,
          favoriteSongsCount: songsCount,
          favoritePlaylistsCount: playlistsCount,
          downloadedSongsCount: downloadedCount,
        ),
      );
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoadingStats: false));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _updateProfileUseCase(UpdateProfileParams(
      name: name,
      email: email,
      avatar: avatar,
    ));

    result.fold(
      (error) {
        if (isClosed) return;
        emit(state.copyWith(
          isLoading: false,
          errorMessage: getErrorMessage(error),
        ));
      },
      (updatedProfile) {
        if (isClosed) return;
        emit(
          state.copyWith(
            isLoading: false,
            profile: updatedProfile,
            firstName: updatedProfile.firstName,
            lastName: updatedProfile.lastName,
            avatarUrl: updatedProfile.avatar,
          ),
        );
      },
    );
  }

  Future<void> logout() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    final result = await _logoutUseCase();

    await _authManager.logout();

    result.fold(
      (error) {
        if (isClosed) return;
        emit(state.copyWith(
          isLoading: false,
          errorMessage: getErrorMessage(error),
        ));
      },
      (_) {
        if (isClosed) return;
        emit(const ProfileState());
      },
    );
  }

  Future<bool> isLoggedIn() async {
    return _authManager.isUserLoggedIn();
  }

  Future<String?> getToken() async {
    return _authManager.getCurrentAccessToken();
  }
}
