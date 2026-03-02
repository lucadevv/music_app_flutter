import 'package:equatable/equatable.dart';
import 'package:music_app/features/search/domain/entities/thumbnail.dart';
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
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  /// Obtiene la mejor thumbnail de la playlist
  Thumbnail? get bestThumbnail {
    if (response == null || response!.thumbnails.isEmpty) return null;
    
    Thumbnail? best;
    for (final thumbnail in response!.thumbnails) {
      if (best == null || thumbnail.width > best.width) {
        best = thumbnail;
      }
    }
    return best;
  }

  @override
  List<Object?> get props => [status, response, errorMessage];
}
