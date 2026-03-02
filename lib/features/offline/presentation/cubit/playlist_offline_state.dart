part of 'playlist_offline_cubit.dart';

/// Estados del status para las operaciones de playlists offline
enum PlaylistOfflineStatus { idle, loading, success, failure }

/// Estado del PlaylistOfflineCubit
///
/// Gestiona el estado de las playlists cacheadas para uso offline,
/// incluyendo la lista de playlists y el seguimiento de sincronizaciones en curso.
class PlaylistOfflineState {
  /// Estado actual de la operación
  final PlaylistOfflineStatus status;

  /// Lista de playlists cacheadas offline
  final List<OfflinePlaylist> playlists;

  /// IDs de playlists que están siendo sincronizadas actualmente
  final Set<String> syncingPlaylistIds;

  /// Mensaje de error si ocurre una falla
  final String? errorMessage;

  const PlaylistOfflineState({
    this.status = PlaylistOfflineStatus.idle,
    this.playlists = const [],
    this.syncingPlaylistIds = const {},
    this.errorMessage,
  });

  /// Crea una copia del estado con los valores proporcionados
  PlaylistOfflineState copyWith({
    PlaylistOfflineStatus? status,
    List<OfflinePlaylist>? playlists,
    Set<String>? syncingPlaylistIds,
    String? errorMessage,
    bool clearError = false,
  }) {
    return PlaylistOfflineState(
      status: status ?? this.status,
      playlists: playlists ?? this.playlists,
      syncingPlaylistIds: syncingPlaylistIds ?? this.syncingPlaylistIds,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Verifica si una playlist específica está siendo sincronizada
  bool isSyncing(String playlistId) => syncingPlaylistIds.contains(playlistId);

  /// Obtiene una playlist por ID desde el cache local
  OfflinePlaylist? getPlaylistById(String playlistId) {
    try {
      return playlists.firstWhere((p) => p.playlistId == playlistId);
    } catch (_) {
      return null;
    }
  }

  /// Verifica si una playlist está en el cache offline
  bool isPlaylistCached(String playlistId) {
    return playlists.any((p) => p.playlistId == playlistId);
  }

  /// Número de playlists cacheadas
  int get playlistCount => playlists.length;

  /// Indica si hay una operación en curso
  bool get isLoading => status == PlaylistOfflineStatus.loading;

  /// Indica si el estado tiene un error
  bool get hasError =>
      status == PlaylistOfflineStatus.failure && errorMessage != null;
}
