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
  
  // Estado de carga de playlist para reproducción
  final int loadedCount;
  final int totalCount;
  final bool isLoadingForPlay;

  const PlaylistState({
    this.status = PlaylistStatus.initial,
    this.response,
    this.errorMessage,
    this.loadedCount = 0,
    this.totalCount = 0,
    this.isLoadingForPlay = false,
  });

  PlaylistState copyWith({
    PlaylistStatus? status,
    PlaylistResponse? response,
    String? errorMessage,
    int? loadedCount,
    int? totalCount,
    bool? isLoadingForPlay,
  }) {
    return PlaylistState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
      loadedCount: loadedCount ?? this.loadedCount,
      totalCount: totalCount ?? this.totalCount,
      isLoadingForPlay: isLoadingForPlay ?? this.isLoadingForPlay,
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
  List<Object?> get props => [status, response, errorMessage, loadedCount, totalCount, isLoadingForPlay];
}
