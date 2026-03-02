part of 'downloads_cubit.dart';

/// Estados del feature de descargas
enum DownloadsStatus { initial, loading, success, failure }

/// Estado del cubit de descargas
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar el estado de las descargas
class DownloadsState extends Equatable {
  final DownloadsStatus status;
  final String? errorMessage;
  final List<DownloadedSong> downloadedSongs;
  final Set<String> downloadingIds;
  final Map<String, double> downloadProgress;

  const DownloadsState({
    this.status = DownloadsStatus.initial,
    this.errorMessage,
    this.downloadedSongs = const [],
    this.downloadingIds = const {},
    this.downloadProgress = const {},
  });

  /// Crea una copia del estado con los cambios proporcionados
  DownloadsState copyWith({
    DownloadsStatus? status,
    String? errorMessage,
    List<DownloadedSong>? downloadedSongs,
    Set<String>? downloadingIds,
    Map<String, double>? downloadProgress,
    bool clearError = false,
  }) {
    return DownloadsState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      downloadedSongs: downloadedSongs ?? this.downloadedSongs,
      downloadingIds: downloadingIds ?? this.downloadingIds,
      downloadProgress: downloadProgress ?? this.downloadProgress,
    );
  }

  /// Getters de conveniencia
  bool get isLoading => status == DownloadsStatus.loading;
  bool get isSuccess => status == DownloadsStatus.success;
  bool get isFailure => status == DownloadsStatus.failure;
  bool get hasDownloads => downloadedSongs.isNotEmpty;
  bool get hasActiveDownloads => downloadingIds.isNotEmpty;

  @override
  List<Object?> get props => [
    status,
    errorMessage,
    downloadedSongs,
    downloadingIds,
    downloadProgress,
  ];
}
