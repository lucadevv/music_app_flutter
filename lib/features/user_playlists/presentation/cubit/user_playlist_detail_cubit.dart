import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/domain/use_cases/add_song_to_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/delete_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/remove_song_from_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/update_user_playlist_use_case.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/user_playlists/presentation/cubit/user_playlist_detail_state.dart';

/// Cubit para manejar el detalle de playlist de usuario
///
/// Responsibilities:
/// - Cargar playlist
/// - Reproducir canciones
/// - Editar playlist
/// - Eliminar playlist
/// - Eliminar canción de playlist
class UserPlaylistDetailCubit extends Cubit<UserPlaylistDetailState>
    with BaseBlocMixin {
  final GetUserPlaylistUseCase _getUserPlaylistUseCase;
  final UpdateUserPlaylistUseCase _updateUserPlaylistUseCase;
  final DeleteUserPlaylistUseCase _deleteUserPlaylistUseCase;
  final AddSongToUserPlaylistUseCase _addSongToUserPlaylistUseCase;
  final RemoveSongFromUserPlaylistUseCase _removeSongFromUserPlaylistUseCase;
  final PlayerBlocBloc _playerBloc;

  bool _isLoadingPlayback = false;
  StreamSubscription? _playbackStartedSubscription;

  UserPlaylistDetailCubit({
    required GetUserPlaylistUseCase getUserPlaylistUseCase,
    required UpdateUserPlaylistUseCase updateUserPlaylistUseCase,
    required DeleteUserPlaylistUseCase deleteUserPlaylistUseCase,
    required AddSongToUserPlaylistUseCase addSongToUserPlaylistUseCase,
    required RemoveSongFromUserPlaylistUseCase
    removeSongFromUserPlaylistUseCase,
    required PlayerBlocBloc playerBloc,
  }) : _getUserPlaylistUseCase = getUserPlaylistUseCase,
       _updateUserPlaylistUseCase = updateUserPlaylistUseCase,
       _deleteUserPlaylistUseCase = deleteUserPlaylistUseCase,
       _addSongToUserPlaylistUseCase = addSongToUserPlaylistUseCase,
       _removeSongFromUserPlaylistUseCase = removeSongFromUserPlaylistUseCase,
       _playerBloc = playerBloc,
       super(const UserPlaylistDetailState()) {
    _listenToPlaybackStarted();
  }

  void _listenToPlaybackStarted() {
    _playbackStartedSubscription = _playerBloc.playlistPlaybackStartedStream
        .listen((event) {
          if (event.sourceId == state.playlist?.id && _isLoadingPlayback) {
            debugPrint(
              'UserPlaylistDetailCubit: Playback started for ${event.sourceId}',
            );
            _isLoadingPlayback = false;
          }
        });
  }

  /// Carga una playlist por ID
  Future<void> loadPlaylist(String playlistId) async {
    emit(state.copyWith(status: UserPlaylistDetailStatus.loading));

    try {
      final result = await _getUserPlaylistUseCase(playlistId);

      result.fold(
        (error) => emit(
          state.copyWith(
            status: UserPlaylistDetailStatus.failure,
            errorMessage: error.message,
          ),
        ),
        (playlist) => emit(
          state.copyWith(
            status: UserPlaylistDetailStatus.success,
            playlist: playlist,
          ),
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: UserPlaylistDetailStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  /// Reproduce todas las canciones
  /// Si already have a song playing from this playlist, toggle play/pause
  /// Otherwise, load entire playlist with sourceId
  void playAll() {
    debugPrint('DEBUG ========== playAll() LLAMADO ==========');
    if (state.playlist == null || state.playlist!.songs.isEmpty) {
      debugPrint('DEBUG playAll: playlist es null o vacía, retornando');
      return;
    }

    if (_isLoadingPlayback) {
      debugPrint('DEBUG playAll: Ya hay una carga en progreso, ignorando');
      return;
    }

    final playlist = state.playlist!.songs
        .where((s) => s.streamUrl != null && s.streamUrl!.isNotEmpty)
        .map(
          (s) => NowPlayingData.fromBasic(
            videoId: s.videoId,
            title: s.title,
            artistNames: [s.artist],
            albumName: '',
            duration: s.duration != null
                ? _formatDuration(s.duration!)
                : '0:00',
            durationSeconds: s.duration,
            thumbnailUrl: s.thumbnail,
            streamUrl: s.streamUrl,
          ),
        )
        .toList();

    if (playlist.isEmpty) {
      debugPrint('DEBUG playAll: No hay canciones con streamUrl válido');
      return;
    }

    debugPrint(
      'DEBUG playAll: Cargando playlist con ${playlist.length} canciones',
    );
    debugPrint('DEBUG playAll: sourceId = ${state.playlist!.id}');

    _isLoadingPlayback = true;

    _playerBloc.add(
      LoadPlaylistEvent(
        playlist: playlist,
        startIndex: 0,
        sourceId: state.playlist!.id,
      ),
    );
    debugPrint('DEBUG playAll: LoadPlaylistEvent enviado');
  }

  /// Reproduce una canción específica de la playlist
  void playSong(int index) {
    debugPrint('DEBUG ========== playSong($index) LLAMADO ==========');
    if (state.playlist == null || state.playlist!.songs.isEmpty) {
      debugPrint('DEBUG playSong: playlist es null o vacía, retornando');
      return;
    }

    if (index < 0 || index >= state.playlist!.songs.length) {
      debugPrint('DEBUG playSong: índice fuera de rango');
      return;
    }

    if (_isLoadingPlayback) {
      debugPrint('DEBUG playSong: Ya hay una carga en progreso, ignorando');
      return;
    }

    final playlist = state.playlist!.songs
        .where((s) => s.streamUrl != null && s.streamUrl!.isNotEmpty)
        .map(
          (s) => NowPlayingData.fromBasic(
            videoId: s.videoId,
            title: s.title,
            artistNames: [s.artist],
            albumName: '',
            duration: s.duration != null
                ? _formatDuration(s.duration!)
                : '0:00',
            durationSeconds: s.duration,
            thumbnailUrl: s.thumbnail,
            streamUrl: s.streamUrl,
          ),
        )
        .toList();

    if (playlist.isEmpty) {
      debugPrint('DEBUG playSong: No hay canciones con streamUrl válido');
      return;
    }

    debugPrint('DEBUG playSong: Cargando playlist desde índice $index');
    debugPrint('DEBUG playSong: sourceId = ${state.playlist!.id}');

    _isLoadingPlayback = true;

    _playerBloc.add(
      LoadPlaylistEvent(
        playlist: playlist,
        startIndex: index,
        sourceId: state.playlist!.id,
      ),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  /// Actualiza el nombre de la playlist
  Future<void> updatePlaylist(String playlistId, String name) async {
    try {
      final result = await _updateUserPlaylistUseCase(playlistId, name: name);

      result.fold(
        (error) => emit(state.copyWith(errorMessage: error.message)),
        (playlist) => emit(state.copyWith(playlist: playlist)),
      );

      await loadPlaylist(playlistId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Elimina la playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      final result = await _deleteUserPlaylistUseCase(playlistId);

      result.fold(
        (error) => emit(state.copyWith(errorMessage: error.message)),
        (_) => null, // Success - the caller should handle navigation
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Elimina una canción de la playlist
  Future<void> removeSong(String playlistId, String songId) async {
    try {
      final result = await _removeSongFromUserPlaylistUseCase(
        playlistId,
        songId,
      );

      result.fold(
        (error) => emit(state.copyWith(errorMessage: error.message)),
        (_) => loadPlaylist(playlistId),
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Agrega una canción a la playlist
  Future<bool> addSongToPlaylist({
    required String playlistId,
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? duration,
  }) async {
    try {
      final result = await _addSongToUserPlaylistUseCase(
        playlistId,
        videoId: videoId,
        title: title,
        artist: artist,
        thumbnail: thumbnail,
        duration: duration,
      );

      return result.fold(
        (error) {
          emit(state.copyWith(errorMessage: error.message));
          return false;
        },
        (playlist) {
          emit(state.copyWith(playlist: playlist));
          return true;
        },
      );
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
      return false;
    }
  }

  @override
  Future<void> close() {
    _playbackStartedSubscription?.cancel();
    return super.close();
  }
}
