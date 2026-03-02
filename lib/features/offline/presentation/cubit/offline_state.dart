part of 'offline_cubit.dart';

/// Estado del modo offline
enum OfflineStatus { initial, loading, ready, error }

/// Estado del cubit de offline
class OfflineState {
  /// Estado actual de inicialización
  final OfflineStatus status;

  /// Indica si hay conexión a internet
  final bool isOnline;

  /// Número de canciones guardadas offline
  final int offlineSongsCount;

  /// Número de playlists guardadas offline
  final int offlinePlaylistsCount;

  /// Último error encontrado
  final String? error;

  /// Mensaje de estado de sincronización
  final String? syncMessage;

  const OfflineState({
    this.status = OfflineStatus.initial,
    this.isOnline = true,
    this.offlineSongsCount = 0,
    this.offlinePlaylistsCount = 0,
    this.error,
    this.syncMessage,
  });

  OfflineState copyWith({
    OfflineStatus? status,
    bool? isOnline,
    int? offlineSongsCount,
    int? offlinePlaylistsCount,
    String? error,
    String? syncMessage,
    bool clearError = false,
    bool clearSyncMessage = false,
  }) {
    return OfflineState(
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      offlineSongsCount: offlineSongsCount ?? this.offlineSongsCount,
      offlinePlaylistsCount:
          offlinePlaylistsCount ?? this.offlinePlaylistsCount,
      error: clearError ? null : (error ?? this.error),
      syncMessage: clearSyncMessage ? null : (syncMessage ?? this.syncMessage),
    );
  }
}
