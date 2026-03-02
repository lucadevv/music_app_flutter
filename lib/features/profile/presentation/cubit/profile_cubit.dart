import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/features/profile/data/services/profile_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> with BaseBlocMixin {
  final ProfileService _profileService;
  final ApiServices _apiServices;
  final AuthManager _authManager;

  ProfileCubit(
    this._profileService,
    this._apiServices,
    this._authManager,
  ) : super(const ProfileState());

  Future<void> loadProfile() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final profile = await _profileService.getProfile();

      if (isClosed) return;

      emit(state.copyWith(
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
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        isLoading: false,
        errorMessage: getErrorMessage(e),
      ));
    }
  }

  Future<void> loadSettings() async {
    if (state.isSettingsLoading) return;

    emit(state.copyWith(isSettingsLoading: true, clearSettingsError: true));

    try {
      final settings = await _profileService.getSettings();

      if (isClosed) return;

      emit(state.copyWith(
        isSettingsLoading: false,
        settings: settings,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        isSettingsLoading: false,
        settingsError: getErrorMessage(e),
      ));
    }
  }

  Future<void> updateSettings(UserSettings settings) async {
    if (state.isSettingsLoading) return;

    emit(state.copyWith(isSettingsLoading: true, clearSettingsError: true));

    try {
      final updatedSettings = await _profileService.updateSettings(settings);

      if (isClosed) return;

      emit(state.copyWith(
        isSettingsLoading: false,
        settings: updatedSettings,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        isSettingsLoading: false,
        settingsError: getErrorMessage(e),
      ));
    }
  }

  Future<void> updateLanguage(String language) async {
    final currentSettings = state.settings ?? const UserSettings();
    final newSettings = currentSettings.copyWith(language: language);
    await updateSettings(newSettings);
  }

  Future<void> updateStreamingQuality(String quality) async {
    final currentSettings = state.settings ?? const UserSettings();
    final newSettings = currentSettings.copyWith(streamingQuality: quality);
    await updateSettings(newSettings);
  }

  Future<void> updateDownloadQuality(String quality) async {
    final currentSettings = state.settings ?? const UserSettings();
    final newSettings = currentSettings.copyWith(downloadQuality: quality);
    await updateSettings(newSettings);
  }

  Future<void> updateEqualizerPreset(String preset) async {
    final currentSettings = state.settings ?? const UserSettings();
    final newSettings = currentSettings.copyWith(equalizerPreset: preset);
    await updateSettings(newSettings);
  }

  Future<void> loadLibraryStats() async {
    if (state.isLoadingStats) return;

    emit(state.copyWith(isLoadingStats: true));

    try {
      final summary = await _profileService.getLibrarySummary();

      if (isClosed) return;

      emit(state.copyWith(
        isLoadingStats: false,
        favoriteSongsCount: summary.favoriteSongsCount,
        favoritePlaylistsCount: summary.favoritePlaylistsCount,
        favoriteGenresCount: summary.favoriteGenresCount,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        isLoadingStats: false,
      ));
    }
  }

  Future<void> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final updatedProfile = await _profileService.updateProfile(
        name: name,
        email: email,
        avatar: avatar,
      );

      if (isClosed) return;

      emit(state.copyWith(
        isLoading: false,
        profile: updatedProfile,
        firstName: updatedProfile.firstName,
        lastName: updatedProfile.lastName,
        avatarUrl: updatedProfile.avatar,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        isLoading: false,
        errorMessage: getErrorMessage(e),
      ));
    }
  }

  Future<void> logout() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      await _profileService.logout();
      await _authManager.logout();

      if (isClosed) return;

      emit(const ProfileState());
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        isLoading: false,
        errorMessage: getErrorMessage(e),
      ));
    }
  }

  bool get isLoggedIn => _authManager.isLoggedIn;

  String? get token => _authManager.accessToken;
}
