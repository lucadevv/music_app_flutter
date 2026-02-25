import 'package:equatable/equatable.dart';
import '../../domain/entities/playlist_response.dart';

/// Estados posibles del cubit de playlist
enum PlaylistStatus { initial, loading, success, failure }

/// Estado del cubit de playlist
class PlaylistState extends Equatable {
  final PlaylistStatus status;
  final PlaylistResponse? response;
  final String? errorMessage;

  const PlaylistState({
    this.status = PlaylistStatus.initial,
    this.response,
    this.errorMessage,
  });

  PlaylistState copyWith({
    PlaylistStatus? status,
    PlaylistResponse? response,
    String? errorMessage,
  }) {
    return PlaylistState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, response, errorMessage];
}
