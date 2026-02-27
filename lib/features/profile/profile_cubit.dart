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
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(
        isLoading: false,
        error: _parseError(e),
      ));
    }
  }

  String _parseError(dynamic error) {
    return error?.toString() ?? 'An error occurred';
  }
}
