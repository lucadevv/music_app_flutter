import 'package:equatable/equatable.dart';
import 'package:music_app/features/search/domain/entities/thumbnail.dart';
import '../../domain/entities/playlist_response.dart';
import '../../domain/entities/playlist_track.dart';

/// Estados posibles del cubit de playlist
enum PlaylistStatus { initial, loading, loadingMore, success, failure }

/// Estado del cubit de playlist
class PlaylistState extends Equatable {
  final PlaylistStatus status;
  final PlaylistResponse? response;
  final String? errorMessage;
  
  // Estado de carga de playlist para reproducción
  final int loadedCount;
  final int totalCount;
  final bool isLoadingForPlay;
  final String? loadingPlaylistId; // ID de la playlist que está cargando
  
  // Estado de paginación
  final int currentPage;
  final bool hasMore;
  final List<PlaylistTrack> allTracks; // Tracks acumulados para reproducción
  final String _filterQuery;

  const PlaylistState({
    this.status = PlaylistStatus.initial,
    this.response,
    this.errorMessage,
    this.loadedCount = 0,
    this.totalCount = 0,
    this.isLoadingForPlay = false,
    this.loadingPlaylistId,
    this.currentPage = 0,
    this.hasMore = true,
    this.allTracks = const [],
    String filterQuery = '',
  }) : _filterQuery = filterQuery;

  /// Retorna los tracks de la respuesta actual filtrados por query (Lógica de Dominio)
  List<PlaylistTrack> get filteredResponseTracks {
    if (response == null) return [];
    if (_filterQuery.isEmpty) return response!.tracks;
    return response!.tracks.where((track) => track.matchesQuery(_filterQuery)).toList();
  }

  PlaylistState copyWith({
    PlaylistStatus? status,
    PlaylistResponse? response,
    String? errorMessage,
    int? loadedCount,
    int? totalCount,
    bool? isLoadingForPlay,
    String? loadingPlaylistId,
    int? currentPage,
    bool? hasMore,
    List<PlaylistTrack>? allTracks,
    String? filterQuery,
    bool clearLoadingPlaylistId = false,
  }) {
    return PlaylistState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
      loadedCount: loadedCount ?? this.loadedCount,
      totalCount: totalCount ?? this.totalCount,
      isLoadingForPlay: isLoadingForPlay ?? this.isLoadingForPlay,
      loadingPlaylistId: clearLoadingPlaylistId ? null : (loadingPlaylistId ?? this.loadingPlaylistId),
      currentPage: currentPage ?? this.currentPage,
      hasMore: hasMore ?? this.hasMore,
      allTracks: allTracks ?? this.allTracks,
      filterQuery: filterQuery ?? _filterQuery,
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
  List<Object?> get props => [status, response, errorMessage, loadedCount, totalCount, isLoadingForPlay, loadingPlaylistId, currentPage, hasMore, allTracks];
}
