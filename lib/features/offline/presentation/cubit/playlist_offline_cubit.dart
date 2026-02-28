import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/data/offline/models/offline_playlist.dart';
import 'package:music_app/data/offline/services/offline_service.dart';
import 'package:music_app/features/library/library_service.dart';

part 'playlist_offline_state.dart';

/// Cubit para gestionar el caché offline de playlists
///
/// Proporciona métodos para cargar, sincronizar y eliminar playlists
/// del almacenamiento local (Hive) para uso sin conexión.
///
/// Sigue el patrón Clean Architecture con inyección de dependencias
/// y usa BaseBlocMixin para el manejo centralizado de errores.
class PlaylistOfflineCubit extends Cubit<PlaylistOfflineState> with BaseBlocMixin {
  final OfflineService _offlineService;

  /// Constructor con inyección de dependencias
  PlaylistOfflineCubit(this._offlineService) : super(const PlaylistOfflineState());

  /// Carga todas las playlists offline desde Hive
  ///
  /// Actualiza el estado con la lista de playlists cacheadas.
  /// Si ocurre un error, actualiza el estado con el mensaje de error.
  Future<void> loadOfflinePlaylists() async {
    if (state.isLoading) return;

    emit(state.copyWith(status: PlaylistOfflineStatus.loading, clearError: true));

    try {
      final playlists = await _offlineService.getOfflinePlaylists();

      if (isClosed) return;

      emit(state.copyWith(
        status: PlaylistOfflineStatus.success,
        playlists: playlists,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        status: PlaylistOfflineStatus.failure,
        errorMessage: _parseError(e),
      ));
    }
  }

  /// Sincroniza (guarda) una playlist en el caché offline
  ///
  /// Recibe los datos de la playlist desde [FavoritePlaylist] y la
  /// convierte a [OfflinePlaylist] para almacenarla en Hive.
  ///
  /// Si la playlist ya existe, actualiza sus datos manteniendo
  /// la miniatura local si existe.
  Future<void> syncPlaylist(FavoritePlaylist playlistData) async {
    final playlistId = playlistData.playlistId;

    // Marcar como sincronizando
    final newSyncingIds = Set<String>.from(state.syncingPlaylistIds)..add(playlistId);
    emit(state.copyWith(syncingPlaylistIds: newSyncingIds));

    try {
      // Obtener playlist existente para mantener datos locales
      final existingPlaylist = _offlineService.getPlaylistById(playlistId);

      // Crear OfflinePlaylist desde FavoritePlaylist
      final offlinePlaylist = OfflinePlaylist()
        ..playlistId = playlistData.playlistId
        ..externalPlaylistId = playlistData.externalPlaylistId
        ..name = playlistData.name
        ..description = playlistData.description
        ..thumbnail = playlistData.thumbnail
        ..trackCount = playlistData.trackCount ?? 0
        ..createdAt = playlistData.createdAt
        ..lastSyncedAt = DateTime.now()
        ..videoIds = existingPlaylist?.videoIds ?? [];

      // Mantener miniatura local si existe
      if (existingPlaylist?.localThumbnailPath != null) {
        offlinePlaylist.localThumbnailPath = existingPlaylist!.localThumbnailPath;
      }

      // Guardar en Hive
      await _offlineService.saveOfflinePlaylist(offlinePlaylist);

      if (isClosed) return;

      // Actualizar lista local sin recargar todo
      final updatedPlaylists = List<OfflinePlaylist>.from(state.playlists);
      final existingIndex = updatedPlaylists.indexWhere((p) => p.playlistId == playlistId);

      if (existingIndex >= 0) {
        updatedPlaylists[existingIndex] = offlinePlaylist;
      } else {
        updatedPlaylists.add(offlinePlaylist);
      }

      // Remover de syncing y actualizar playlists
      final newSyncingIdsAfter = Set<String>.from(state.syncingPlaylistIds)..remove(playlistId);
      emit(state.copyWith(
        status: PlaylistOfflineStatus.success,
        playlists: updatedPlaylists,
        syncingPlaylistIds: newSyncingIdsAfter,
      ));
    } catch (e) {
      if (isClosed) return;

      // Remover de syncing en caso de error
      final newSyncingIds = Set<String>.from(state.syncingPlaylistIds)..remove(playlistId);
      emit(state.copyWith(
        status: PlaylistOfflineStatus.failure,
        errorMessage: _parseError(e),
        syncingPlaylistIds: newSyncingIds,
      ));
    }
  }

  /// Elimina una playlist del caché offline
  ///
  /// Remueve la playlist de Hive y actualiza el estado local.
  Future<void> removeOfflinePlaylist(String playlistId) async {
    emit(state.copyWith(status: PlaylistOfflineStatus.loading, clearError: true));

    try {
      await _offlineService.deleteOfflinePlaylist(playlistId);

      if (isClosed) return;

      // Actualizar lista local sin recargar todo
      final updatedPlaylists = state.playlists
          .where((p) => p.playlistId != playlistId)
          .toList();

      emit(state.copyWith(
        status: PlaylistOfflineStatus.success,
        playlists: updatedPlaylists,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        status: PlaylistOfflineStatus.failure,
        errorMessage: _parseError(e),
      ));
    }
  }

  /// Obtiene una playlist por ID desde el caché offline
  ///
  /// Retorna null si la playlist no existe en el caché.
  OfflinePlaylist? getOfflinePlaylist(String playlistId) {
    return _offlineService.getPlaylistById(playlistId);
  }

  /// Sincroniza todas las playlists favoritas
  ///
  /// Itera sobre la lista de [FavoritePlaylist] y sincroniza cada una
  /// con el caché offline. Las playlists que ya no están en favoritos
  /// son eliminadas del caché.
  Future<void> syncAllFavoritePlaylists(List<FavoritePlaylist> playlists) async {
    if (state.isLoading) return;

    emit(state.copyWith(status: PlaylistOfflineStatus.loading, clearError: true));

    try {
      final syncedIds = <String>{};

      for (final playlistData in playlists) {
        final playlistId = playlistData.playlistId;
        syncedIds.add(playlistId);

        // Obtener playlist existente para mantener datos locales
        final existingPlaylist = _offlineService.getPlaylistById(playlistId);

        // Crear OfflinePlaylist
        final offlinePlaylist = OfflinePlaylist()
          ..playlistId = playlistData.playlistId
          ..externalPlaylistId = playlistData.externalPlaylistId
          ..name = playlistData.name
          ..description = playlistData.description
          ..thumbnail = playlistData.thumbnail
          ..trackCount = playlistData.trackCount ?? 0
          ..createdAt = playlistData.createdAt
          ..lastSyncedAt = DateTime.now()
          ..videoIds = existingPlaylist?.videoIds ?? [];

        // Mantener miniatura local si existe
        if (existingPlaylist?.localThumbnailPath != null) {
          offlinePlaylist.localThumbnailPath = existingPlaylist!.localThumbnailPath;
        }

        await _offlineService.saveOfflinePlaylist(offlinePlaylist);
      }

      // Eliminar playlists que ya no están en favoritos
      final currentPlaylists = await _offlineService.getOfflinePlaylists();
      for (final cached in currentPlaylists) {
        if (!syncedIds.contains(cached.playlistId)) {
          await _offlineService.deleteOfflinePlaylist(cached.playlistId);
        }
      }

      if (isClosed) return;

      // Recargar lista actualizada
      final updatedPlaylists = await _offlineService.getOfflinePlaylists();

      if (isClosed) return;

      emit(state.copyWith(
        status: PlaylistOfflineStatus.success,
        playlists: updatedPlaylists,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        status: PlaylistOfflineStatus.failure,
        errorMessage: _parseError(e),
      ));
    }
  }

  /// Limpia el mensaje de error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Parsea errores a mensajes legibles
  String _parseError(dynamic error) {
    if (error is AppException) {
      return getErrorMessage(error);
    }
    return error?.toString() ?? 'Ha ocurrido un error desconocido';
  }
}
