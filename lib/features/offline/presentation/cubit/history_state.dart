part of 'history_cubit.dart';

/// Estados del feature de historial de reproducción
enum HistoryStatus { initial, loading, success, failure }

/// Estado del cubit de historial de reproducción offline
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar el estado del historial de reproducción
class HistoryState extends Equatable {
  /// Estado actual de la operación
  final HistoryStatus status;

  /// Lista de reproducciones en el historial
  final List<OfflineHistory> history;

  /// Estadísticas de reproducción
  final HistoryStats? stats;

  /// ID de la entrada de historial que se está reproduciendo actualmente
  final String? currentHistoryId;

  /// Mensaje de error si ocurre alguno
  final String? errorMessage;

  const HistoryState({
    this.status = HistoryStatus.initial,
    this.history = const [],
    this.stats,
    this.currentHistoryId,
    this.errorMessage,
  });

  /// Crea una copia del estado con los cambios proporcionados
  HistoryState copyWith({
    HistoryStatus? status,
    List<OfflineHistory>? history,
    HistoryStats? stats,
    String? currentHistoryId,
    bool clearCurrentHistoryId = false,
    String? errorMessage,
    bool clearError = false,
    bool clearStats = false,
  }) {
    return HistoryState(
      status: status ?? this.status,
      history: history ?? this.history,
      stats: clearStats ? null : (stats ?? this.stats),
      currentHistoryId: clearCurrentHistoryId
          ? null
          : (currentHistoryId ?? this.currentHistoryId),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  /// Getters de conveniencia
  bool get isLoading => status == HistoryStatus.loading;
  bool get isSuccess => status == HistoryStatus.success;
  bool get isFailure => status == HistoryStatus.failure;
  bool get hasHistory => history.isNotEmpty;
  bool get hasStats => stats != null;
  bool get isPlaying => currentHistoryId != null;

  @override
  List<Object?> get props => [
    status,
    history,
    stats,
    currentHistoryId,
    errorMessage,
  ];
}
