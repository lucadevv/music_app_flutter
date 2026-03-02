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
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        isLoading: false,
        errorMessage: getErrorMessage(e),
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
