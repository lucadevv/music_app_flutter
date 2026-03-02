import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/domain/use_cases/check_download_status_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/download_song_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/get_downloaded_songs_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/remove_download_use_case.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
// Removed unused import: thumbnail

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
  final PlayerBlocBloc _playerBloc;

  DownloadsCubit(
    this._downloadSongUseCase,
    this._getDownloadedSongsUseCase,
    this._removeDownloadUseCase,
    this._checkDownloadStatusUseCase,
    this._playerBloc,
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
      emit(
        state.copyWith(
          status: DownloadsStatus.failure,
          errorMessage: getErrorMessage(error),
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: DownloadsStatus.success,
        downloadedSongs: songs ?? [],
      ),
    );
  }

  /// Descarga una canción
  Future<void> downloadSong({
    required String videoId,
    required String title,
    required String artist,
    required String streamUrl,
    required Duration duration,
    String? album,
    String? thumbnail,
  }) async {
    // Marcar como descargando
    emit(
      state.copyWith(
        downloadingIds: {...state.downloadingIds, videoId},
        downloadProgress: {...state.downloadProgress, videoId: 0.0},
      ),
    );

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
            emit(
              state.copyWith(
                downloadProgress: {
                  ...state.downloadProgress,
                  videoId: progress,
                },
              ),
            );
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
      emit(
        state.copyWith(
          downloadingIds: newDownloadingIds,
          downloadProgress: newProgress,
          errorMessage: getErrorMessage(error),
        ),
      );
      return;
    }

    if (downloadedSong != null) {
      emit(
        state.copyWith(
          downloadingIds: newDownloadingIds,
          downloadProgress: newProgress,
          downloadedSongs: [...state.downloadedSongs, downloadedSong],
        ),
      );
    }
  }

  /// Elimina una descarga
  Future<void> removeDownload(String videoId) async {
    final (error, _) = await _removeDownloadUseCase(videoId);

    if (error != null) {
      emit(state.copyWith(errorMessage: getErrorMessage(error)));
      return;
    }

    emit(
      state.copyWith(
        downloadedSongs: state.downloadedSongs
            .where((song) => song.videoId != videoId)
            .toList(),
      ),
    );
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

  /// Reproduce una canción descargada
  /// Retorna el NowPlayingData para navegación
  NowPlayingData playDownloadedSong(DownloadedSong song) {
    final durationSeconds = song.duration.inSeconds;
    final durationStr = _formatDuration(song.duration.inSeconds);
    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: [song.artist],
      albumName: '',
      duration: durationStr,
      durationSeconds: durationSeconds,
      thumbnailUrl: song.thumbnail,
      streamUrl: 'file://${song.localPath}',
    );

    _playerBloc.add(LoadTrackEvent(nowPlayingData));
    return nowPlayingData;
  }

  /// Reproduce todas las canciones descargadas
  /// Retorna el primer NowPlayingData para navegación
  NowPlayingData? playAllDownloads() {
    if (state.downloadedSongs.isEmpty) return null;

    final playlist = state.downloadedSongs
        .where((song) => song.localPath.isNotEmpty)
        .map((song) {
          final durationSeconds = song.duration.inSeconds;
          return NowPlayingData.fromBasic(
            videoId: song.videoId,
            title: song.title,
            artistNames: [song.artist],
            albumName: '',
            duration: _formatDuration(song.duration.inSeconds),
            durationSeconds: durationSeconds,
            thumbnailUrl: song.thumbnail,
            streamUrl: 'file://${song.localPath}',
          );
        })
        .toList();

    if (playlist.isNotEmpty) {
      _playerBloc.add(LoadPlaylistEvent(playlist: playlist, startIndex: 0));
      return playlist.first;
    }
    return null;
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
