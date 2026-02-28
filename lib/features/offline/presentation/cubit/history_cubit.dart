import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/data/offline/models/offline_history.dart';
import 'package:music_app/data/offline/services/offline_service.dart';

part 'history_state.dart';

/// Cubit para gestionar el historial de reproducción offline
///
/// SOLID:
/// - Single Responsibility: Gestiona solo el estado del historial de reproducción
/// - Dependency Inversion: Depende de OfflineService (abstracción de datos)
///
/// Patrón aplicado: State Management con BLoC/Cubit
///
/// Funcionalidades:
/// - Cargar historial desde almacenamiento local (Hive)
/// - Agregar entradas al historial cuando inicia una reproducción
/// - Actualizar progreso de reproducción
/// - Limpiar historial
/// - Cargar estadísticas de reproducción
class HistoryCubit extends Cubit<HistoryState> with BaseBlocMixin {
  final OfflineService _offlineService;

  HistoryCubit(this._offlineService) : super(const HistoryState());

  /// Carga el historial de reproducción desde Hive
  ///
  /// Ordena las entradas por fecha de reproducción (más recientes primero)
  Future<void> loadHistory() async {
    emit(state.copyWith(status: HistoryStatus.loading, clearError: true));

    try {
      final history = await _offlineService.getHistory();

      if (isClosed) return;

      emit(state.copyWith(
        status: HistoryStatus.success,
        history: history,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  /// Agrega una entrada al historial cuando empieza una reproducción
  ///
  /// Parámetros:
  /// - [songId]: ID único de la canción en el servidor
  /// - [videoId]: Video ID de YouTube
  /// - [title]: Título de la canción
  /// - [artist]: Nombre del artista
  /// - [thumbnail]: URL de la miniatura (opcional)
  /// - [duration]: Duración en segundos (opcional)
  ///
  /// Retorna el [historyId] de la entrada creada
  Future<String?> addToHistory({
    required String songId,
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? duration,
  }) async {
    try {
      final now = DateTime.now();
      final historyId = '${videoId}_${now.millisecondsSinceEpoch}';

      final historyEntry = OfflineHistory.create(
        songId: songId,
        videoId: videoId,
        title: title,
        artist: artist,
        thumbnail: thumbnail,
        duration: duration,
        playedAt: now,
        playedDuration: 0,
      );

      await _offlineService.addToHistory(historyEntry);

      if (isClosed) return historyId;

      // Actualizar el estado con la nueva entrada al inicio de la lista
      final updatedHistory = [historyEntry, ...state.history];
      emit(state.copyWith(
        history: updatedHistory,
        currentHistoryId: historyId,
      ));

      return historyId;
    } catch (e) {
      if (isClosed) return null;

      emit(state.copyWith(
        errorMessage: _getErrorMessage(e),
      ));
      return null;
    }
  }

  /// Actualiza el progreso de reproducción de una entrada del historial
  ///
  /// Parámetros:
  /// - [historyId]: ID de la entrada de historial
  /// - [playedDuration]: Duración reproducida en segundos
  Future<void> updatePlaybackProgress(
    String historyId,
    int playedDuration,
  ) async {
    try {
      await _offlineService.updateHistoryPlayedDuration(
        historyId,
        playedDuration,
      );

      if (isClosed) return;

      // Actualizar la entrada en el estado local
      final updatedHistory = state.history.map((entry) {
        if (entry.historyId == historyId) {
          entry.updatePlayedDuration(playedDuration);
        }
        return entry;
      }).toList();

      emit(state.copyWith(history: updatedHistory));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  /// Limpia todo el historial de reproducción
  Future<void> clearHistory() async {
    emit(state.copyWith(status: HistoryStatus.loading, clearError: true));

    try {
      await _offlineService.clearHistory();

      if (isClosed) return;

      emit(state.copyWith(
        status: HistoryStatus.success,
        history: [],
        stats: null,
        currentHistoryId: null,
      ));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        status: HistoryStatus.failure,
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  /// Carga las estadísticas de reproducción
  ///
  /// Incluye:
  /// - Total de canciones reproducidas
  /// - Total de canciones completadas (>= 95%)
  /// - Tiempo total de reproducción
  /// - Top 5 artistas más escuchados
  Future<void> loadStats() async {
    try {
      final stats = await _offlineService.getHistoryStats();

      if (isClosed) return;

      emit(state.copyWith(stats: stats));
    } catch (e) {
      if (isClosed) return;

      emit(state.copyWith(
        errorMessage: _getErrorMessage(e),
      ));
    }
  }

  /// Limpia el ID de la entrada de historial actual
  ///
  /// Llamar cuando la reproducción se detiene o finaliza
  void clearCurrentHistoryId() {
    emit(state.copyWith(clearCurrentHistoryId: true));
  }

  /// Limpia el mensaje de error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }

  /// Obtiene un mensaje de error legible desde una excepción
  String _getErrorMessage(dynamic error) {
    if (error is AppException) {
      return getErrorMessage(error);
    }
    return error?.toString() ?? 'Error desconocido';
  }
}
