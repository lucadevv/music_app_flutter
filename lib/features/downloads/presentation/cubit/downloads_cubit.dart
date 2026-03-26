import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/downloads/domain/entities/downloaded_song.dart';
import 'package:music_app/features/downloads/domain/use_cases/check_download_status_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/download_song_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/get_downloaded_songs_use_case.dart';
import 'package:music_app/features/downloads/domain/use_cases/remove_download_use_case.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/domain/player_facade.dart';

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
  final PlayerFacade _player;

  DownloadsCubit(
    this._downloadSongUseCase,
    this._getDownloadedSongsUseCase,
    this._removeDownloadUseCase,
    this._checkDownloadStatusUseCase,
    this._player, {
    bool autoLoad = true,
  }) : super(const DownloadsState()) {
    if (autoLoad) {
      // Cargar descargas automáticamente al iniciar
      loadDownloads();
    }
  }

  /// Carga las canciones descargadas
  Future<void> loadDownloads() async {
    if (isClosed) return;

    emit(state.copyWith(status: DownloadsStatus.loading, clearError: true));

    final result = await _getDownloadedSongsUseCase();

    if (isClosed) return;

    result.fold(
      (error) {
        emit(
          state.copyWith(
            status: DownloadsStatus.failure,
            errorMessage: getErrorMessage(error),
          ),
        );
      },
      (songs) {
        emit(
          state.copyWith(
            status: DownloadsStatus.success,
            downloadedSongs: songs,
          ),
        );
      },
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

    final result = await _downloadSongUseCase(
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

    result.fold(
      (error) {
        emit(
          state.copyWith(
            downloadingIds: newDownloadingIds,
            downloadProgress: newProgress,
            errorMessage: getErrorMessage(error),
          ),
        );
      },
      (downloadedSong) {
        emit(
          state.copyWith(
            downloadingIds: newDownloadingIds,
            downloadProgress: newProgress,
            downloadedSongs: [...state.downloadedSongs, downloadedSong],
          ),
        );
      },
    );
  }

  /// Elimina una descarga
  Future<void> removeDownload(String videoId) async {
    final result = await _removeDownloadUseCase(videoId);

    result.fold(
      (error) {
        emit(state.copyWith(errorMessage: getErrorMessage(error)));
      },
      (_) {
        emit(
          state.copyWith(
            downloadedSongs: state.downloadedSongs
                .where((song) => song.videoId != videoId)
                .toList(),
          ),
        );
      },
    );
  }

  /// Verifica si una canción está descargada
  Future<bool> isDownloaded(String videoId) async {
    final result = await _checkDownloadStatusUseCase(videoId);
    return result.fold((_) => false, (isDownloaded) => isDownloaded);
  }

  /// Obtiene el progreso de descarga de una canción
  double getProgress(String videoId) {
    return state.downloadProgress[videoId] ?? 0.0;
  }

  /// Obtiene una canción descargada por su ID de video
  DownloadedSong? getDownloadedSong(String videoId) {
    try {
      return state.downloadedSongs.firstWhere(
        (song) => song.videoId == videoId,
      );
    } catch (_) {
      return null;
    }
  }

  /// Reproduce una canción descargada
  NowPlayingData playDownloadedSong(DownloadedSong song) {
    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: [song.artist],
      albumName: song.album ?? '',
      duration: _formatDuration(song.duration.inSeconds),
      durationSeconds: song.duration.inSeconds,
      thumbnailUrl: song.thumbnail,
      streamUrl: 'file://${song.localPath}',
    );
    _player.playSingle(nowPlayingData);
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
      _player.playPlaylist(
        playlist: playlist,
        startIndex: 0,
        sourceId: 'downloads',
      );
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
