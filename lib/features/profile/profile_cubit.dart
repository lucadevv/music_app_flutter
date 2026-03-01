import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/profile/profile_service.dart';

part 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> with BaseBlocMixin {
  final ProfileService _profileService;

  ProfileCubit(this._profileService) : super(const ProfileState());

  Future<void> loadProfile() async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final profile = await _profileService.getProfile();

      if (isClosed) return;

      emit(ProfileState(
        isLoading: false,
        id: profile.id,
        email: profile.email,
        firstName: profile.firstName,
        lastName: profile.lastName,
        avatarUrl: profile.avatar,
        provider: profile.provider,
        role: profile.role,
        isEmailVerified: profile.isEmailVerified,
        createdAt: profile.createdAt,
        settings: state.settings,
        isSettingsLoading: state.isSettingsLoading,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        error: _parseError(e),
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
        settingsError: _parseError(e),
      ));
    }
  }

  Future<void> updateSettings(UserSettings settings) async {
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
        settingsError: _parseError(e),
      ));
    }
  }

  Future<void> updateStreamingQuality(String quality) async {
    if (state.settings == null) return;
    
    final newSettings = state.settings!.copyWith(streamingQuality: quality);
    await updateSettings(newSettings);
  }

  Future<void> updateDownloadQuality(String quality) async {
    if (state.settings == null) return;
    
    final newSettings = state.settings!.copyWith(downloadQuality: quality);
    await updateSettings(newSettings);
  }

  Future<void> updateAutoPlay(bool value) async {
    if (state.settings == null) return;
    
    final newSettings = state.settings!.copyWith(autoPlay: value);
    await updateSettings(newSettings);
  }

  Future<void> updateShowLyrics(bool value) async {
    if (state.settings == null) return;
    
    final newSettings = state.settings!.copyWith(showLyrics: value);
    await updateSettings(newSettings);
  }

  Future<void> updateEqualizerPreset(String preset) async {
    if (state.settings == null) return;
    
    final newSettings = state.settings!.copyWith(equalizerPreset: preset);
    await updateSettings(newSettings);
  }

  Future<void> updateLanguage(String language) async {
    if (state.settings == null) return;
    
    final newSettings = state.settings!.copyWith(language: language);
    await updateSettings(newSettings);
  }

  String _parseError(dynamic error) {
    return error?.toString() ?? 'An error occurred';
  }
}
