import 'package:equatable/equatable.dart';
import 'package:music_app/features/library/library_service.dart';

/// Estados del UserPlaylistDetailCubit
enum UserPlaylistDetailStatus { initial, loading, success, failure }

/// Estado del detalle de playlist de usuario
class UserPlaylistDetailState extends Equatable {
  final UserPlaylistDetailStatus status;
  final UserPlaylistDetail? playlist;
  final String? errorMessage;

  const UserPlaylistDetailState({
    this.status = UserPlaylistDetailStatus.initial,
    this.playlist,
    this.errorMessage,
  });

  UserPlaylistDetailState copyWith({
    UserPlaylistDetailStatus? status,
    UserPlaylistDetail? playlist,
    String? errorMessage,
  }) {
    return UserPlaylistDetailState(
      status: status ?? this.status,
      playlist: playlist ?? this.playlist,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, playlist, errorMessage];
}
