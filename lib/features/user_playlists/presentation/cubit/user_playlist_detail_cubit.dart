import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
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
  final LibraryService _libraryService;
  final PlayerBlocBloc _playerBloc;

  UserPlaylistDetailCubit({
    required LibraryService libraryService,
    required PlayerBlocBloc playerBloc,
  }) : _libraryService = libraryService,
       _playerBloc = playerBloc,
       super(const UserPlaylistDetailState());

  /// Carga una playlist por ID
  Future<void> loadPlaylist(String playlistId) async {
    emit(state.copyWith(status: UserPlaylistDetailStatus.loading));

    try {
      final response = await _libraryService.getUserPlaylist(playlistId);
      emit(
        state.copyWith(
          status: UserPlaylistDetailStatus.success,
          playlist: response,
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

  /// Reproduce una canción en específico índice
  void playSong(int index) {
    if (state.playlist == null || state.playlist!.songs.isEmpty) return;

    final playlist = state.playlist!.songs
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
          ),
        )
        .toList();

    _playerBloc.add(LoadPlaylistEvent(playlist: playlist, startIndex: index));
  }

  /// Reproduce todas las canciones desde el inicio
  void playAll() {
    playSong(0);
  }

  /// Actualiza el nombre de la playlist
  Future<void> updatePlaylist(String playlistId, String name) async {
    try {
      await _libraryService.updateUserPlaylist(playlistId, name: name);
      await loadPlaylist(playlistId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Elimina la playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _libraryService.deleteUserPlaylist(playlistId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  /// Elimina una canción de la playlist
  Future<void> removeSong(String playlistId, String songId) async {
    try {
      await _libraryService.removeSongFromUserPlaylist(playlistId, songId);
      await loadPlaylist(playlistId);
    } catch (e) {
      emit(state.copyWith(errorMessage: e.toString()));
    }
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}
