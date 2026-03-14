// ignore_for_file: avoid_dynamic_calls
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/data/offline/models/offline_history.dart';
import 'package:music_app/data/offline/models/offline_playlist.dart';
import 'package:music_app/data/offline/models/offline_song.dart';
import 'package:music_app/data/offline/services/offline_service.dart';

part 'offline_state.dart';

/// Cubit para gestionar el modo offline de la aplicación
///
/// Maneja la inicialización de la base de datos offline,
/// sincronización de favoritos y playlists, y monitoreo de conectividad.
class OfflineCubit extends Cubit<OfflineState> {
  final OfflineService _offlineService;
  final ApiServices _apiServices;
  final Connectivity _connectivity;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  OfflineCubit(this._offlineService, this._apiServices, this._connectivity)
    : super(const OfflineState());

  /// Inicializa el servicio offline
  Future<void> init() async {
    if (state.status == OfflineStatus.loading) return;

    emit(state.copyWith(status: OfflineStatus.loading));

    try {
      await _offlineService.init();

      // Escuchar cambios en la conectividad
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
        results,
      ) async {
        final isOnline = !results.contains(ConnectivityResult.none);
        emit(state.copyWith(isOnline: isOnline));

        // Auto-sincronizar cuando vuelve la conexión
        if (isOnline) {
          await syncFavoriteSongs();
          await syncPlaylists();
        }
      });

      // Verificar conectividad inicial
      final isOnline = await _connectivity.checkConnectivity();
      final online = !isOnline.contains(ConnectivityResult.none);

      // Cargar conteos
      final songsCount = await _offlineService.getOfflineSongsCount();
      final playlistsCount =
          (await _offlineService.getOfflinePlaylists()).length;

      emit(
        state.copyWith(
          status: OfflineStatus.ready,
          isOnline: online,
          offlineSongsCount: songsCount,
          offlinePlaylistsCount: playlistsCount,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: OfflineStatus.error,
          error: 'Error initializing offline service: $e',
        ),
      );
    }
  }

  /// Sincroniza las canciones favoritas con el servidor
  Future<void> syncFavoriteSongs() async {
    if (!state.isOnline) {
      emit(state.copyWith(syncMessage: 'No hay conexión a internet'));
      return;
    }

    try {
      emit(state.copyWith(syncMessage: 'Sincronizando canciones favoritas...'));

      // Obtener favoritos del servidor
      final response = await _apiServices.get(
        '/library/songs',
        queryParameters: {'page': 1, 'limit': 100},
      );
      final data = response is Response ? response.data : response;
      final songs = (data['data'] as List?) ?? [];

      // Sincronizar con la base de datos offline
      await _offlineService.syncFavoriteSongs(
        songs.cast<Map<String, dynamic>>(),
      );

      final songsCount = await _offlineService.getOfflineSongsCount();

      emit(
        state.copyWith(
          offlineSongsCount: songsCount,
          syncMessage: 'Sincronizadas ${songs.length} canciones',
        ),
      );

      // Limpiar mensaje después de 3 segundos
      await Future.delayed(const Duration(seconds: 3));
      emit(state.copyWith(clearSyncMessage: true));
    } catch (e) {
      emit(state.copyWith(syncMessage: 'Error sincronizando: $e'));
    }
  }

  /// Sincroniza las playlists con el servidor
  Future<void> syncPlaylists() async {
    if (!state.isOnline) {
      emit(state.copyWith(syncMessage: 'No hay conexión a internet'));
      return;
    }

    try {
      emit(state.copyWith(syncMessage: 'Sincronizando playlists...'));

      // Obtener playlists del servidor
      final response = await _apiServices.get(
        '/library/playlists',
        queryParameters: {'page': 1, 'limit': 100},
      );
      final data = response is Response ? response.data : response;
      final playlists = (data['data'] as List?) ?? [];

      // Sincronizar con la base de datos offline
      await _offlineService.syncPlaylists(
        playlists.cast<Map<String, dynamic>>(),
      );

      final playlistsCount =
          (await _offlineService.getOfflinePlaylists()).length;

      emit(
        state.copyWith(
          offlinePlaylistsCount: playlistsCount,
          syncMessage: 'Sincronizadas ${playlists.length} playlists',
        ),
      );

      // Limpiar mensaje después de 3 segundos
      await Future.delayed(const Duration(seconds: 3));
      emit(state.copyWith(clearSyncMessage: true));
    } catch (e) {
      emit(state.copyWith(syncMessage: 'Error sincronizando playlists: $e'));
    }
  }

  /// Obtiene las canciones guardadas offline
  Future<List<OfflineSong>> getOfflineSongs() async {
    return _offlineService.getOfflineSongs();
  }

  /// Obtiene las playlists guardadas offline
  Future<List<OfflinePlaylist>> getOfflinePlaylists() async {
    return _offlineService.getOfflinePlaylists();
  }

  /// Busca canciones offline por título o artista
  Future<List<OfflineSong>> searchOfflineSongs(String query) async {
    return _offlineService.searchSongs(query);
  }

  /// Agrega al historial de reproducción
  Future<void> addToHistory({
    required String songId,
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? duration,
  }) async {
    final history = OfflineHistory.create(
      songId: songId,
      videoId: videoId,
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      duration: duration,
      playedAt: DateTime.now(),
    );
    await _offlineService.addToHistory(history);
  }

  /// Obtiene el historial de reproducción
  Future<List<OfflineHistory>> getHistory({int limit = 50}) async {
    return _offlineService.getHistory(limit: limit);
  }

  /// Limpia el historial de reproducción
  Future<void> clearHistory() async {
    await _offlineService.clearHistory();
  }

  /// Obtiene estadísticas del historial
  Future<HistoryStats> getHistoryStats() async {
    return _offlineService.getHistoryStats();
  }

  /// Fuerza la verificación de conectividad
  Future<void> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    final isOnline = !result.contains(ConnectivityResult.none);
    emit(state.copyWith(isOnline: isOnline));
  }

  @override
  Future<void> close() {
    _connectivitySubscription?.cancel();
    return super.close();
  }
}
