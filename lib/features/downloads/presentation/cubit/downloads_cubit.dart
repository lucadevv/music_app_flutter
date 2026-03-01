import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/domain/use_cases/check_download_status_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/download_song_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/get_downloaded_songs_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/remove_download_use_case.dart';

part 'downloads_state.dart';

/// Cubit para gestionar el estado de las descargas
///
/// SOLID:
/// - Single Responsibility: Gestiona solo el estado de descargas
/// - Dependency Inversion: Depende de abstracciones (Use Cases)
///
/// Patrón aplicado: State Management con BLoC/Cubit
class DownloadsCubit extends Cubit<DownloadsState> with BaseBlocMixin {
  final DownloadSongUseCase _downloadSongUseCase;
  final GetDownloadedSongsUseCase _getDownloadedSongsUseCase;
  final RemoveDownloadUseCase _removeDownloadUseCase;
  final CheckDownloadStatusUseCase _checkDownloadStatusUseCase;

  DownloadsCubit(
    this._downloadSongUseCase,
    this._getDownloadedSongsUseCase,
    this._removeDownloadUseCase,
    this._checkDownloadStatusUseCase,
  ) : super(const DownloadsState()) {
    // Cargar descargas automáticamente al iniciar
    loadDownloads();
  }

  /// Carga las canciones descargadas
  Future<void> loadDownloads() async {
    if (isClosed) return;
    
    emit(state.copyWith(status: DownloadsStatus.loading, clearError: true));

    final (error, songs) = await _getDownloadedSongsUseCase();

    if (isClosed) return;

    if (error != null) {
      emit(state.copyWith(
        status: DownloadsStatus.failure,
        errorMessage: getErrorMessage(error),
      ));
      return;
    }

    emit(state.copyWith(
      status: DownloadsStatus.success,
      downloadedSongs: songs ?? [],
    ));
  }

  /// Descarga una canción
  Future<void> downloadSong({
    required String videoId,
    required String title,
    required String artist,
    String? album,
    String? thumbnail,
    required String streamUrl,
    required Duration duration,
  }) async {
    // Marcar como descargando
    emit(state.copyWith(
      downloadingIds: {...state.downloadingIds, videoId},
      downloadProgress: {...state.downloadProgress, videoId: 0.0},
    ));

    final (error, downloadedSong) = await _downloadSongUseCase(
      DownloadParams(
        videoId: videoId,
        title: title,
        artist: artist,
        album: album,
        thumbnail: thumbnail,
        streamUrl: streamUrl,
        duration: duration,
        onProgress: (progress) {
          if (!isClosed) {
            emit(state.copyWith(
              downloadProgress: {...state.downloadProgress, videoId: progress},
            ));
          }
        },
      ),
    );

    if (isClosed) return;

    // Remover de la lista de descargando
    final newDownloadingIds = Set<String>.from(state.downloadingIds)
      ..remove(videoId);
    final newProgress = Map<String, double>.from(state.downloadProgress)
      ..remove(videoId);

    if (error != null) {
      emit(state.copyWith(
        downloadingIds: newDownloadingIds,
        downloadProgress: newProgress,
        errorMessage: getErrorMessage(error),
      ));
      return;
    }

    if (downloadedSong != null) {
      emit(state.copyWith(
        downloadingIds: newDownloadingIds,
        downloadProgress: newProgress,
        downloadedSongs: [...state.downloadedSongs, downloadedSong],
      ));
    }
  }

  /// Elimina una descarga
  Future<void> removeDownload(String videoId) async {
    final (error, _) = await _removeDownloadUseCase(videoId);

    if (error != null) {
      emit(state.copyWith(errorMessage: getErrorMessage(error)));
      return;
    }

    emit(state.copyWith(
      downloadedSongs: state.downloadedSongs
          .where((song) => song.videoId != videoId)
          .toList(),
    ));
  }

  /// Verifica si una canción está descargada
  Future<bool> isDownloaded(String videoId) async {
    final (error, isDownloaded) = await _checkDownloadStatusUseCase(videoId);
    return error == null && isDownloaded;
  }

  /// Obtiene el progreso de descarga de una canción
  double getProgress(String videoId) {
    return state.downloadProgress[videoId] ?? 0.0;
  }

  /// Verifica si una canción se está descargando
  bool isDownloading(String videoId) {
    return state.downloadingIds.contains(videoId);
  }

  /// Limpia el mensaje de error
  void clearError() {
    emit(state.copyWith(clearError: true));
  }
}
