import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/song_options/domain/use_cases/add_to_playlist_use_case.dart';
import 'package:music_app/features/song_options/domain/use_cases/create_playlist_use_case.dart';
import 'package:music_app/features/song_options/domain/use_cases/get_user_playlists_use_case.dart';
import 'package:music_app/features/user_playlists/domain/entities/user_playlist_entity.dart';

part 'playlist_dialog_state.dart';

class PlaylistDialogCubit extends Cubit<PlaylistDialogState> {
  final GetUserPlaylistsUseCase _getUserPlaylistsUseCase;
  final AddToPlaylistUseCase _addToPlaylistUseCase;
  final CreatePlaylistUseCase _createPlaylistUseCase;

  PlaylistDialogCubit({
    required GetUserPlaylistsUseCase getUserPlaylistsUseCase,
    required AddToPlaylistUseCase addToPlaylistUseCase,
    required CreatePlaylistUseCase createPlaylistUseCase,
  }) : _getUserPlaylistsUseCase = getUserPlaylistsUseCase,
       _addToPlaylistUseCase = addToPlaylistUseCase,
       _createPlaylistUseCase = createPlaylistUseCase,
       super(PlaylistDialogInitial());

  Future<void> loadPlaylists() async {
    emit(PlaylistDialogLoading());

    final result = await _getUserPlaylistsUseCase();

    result.fold(
      (error) => emit(PlaylistDialogError(_getErrorMessage(error))),
      (playlists) => emit(PlaylistDialogLoaded(playlists: playlists)),
    );
  }

  void searchPlaylists(String query) {
    final currentState = state;
    if (currentState is PlaylistDialogLoaded) {
      emit(currentState.copyWith(searchQuery: query));
    }
  }

  Future<void> addSongToPlaylist({
    required String playlistId,
    required String videoId,
    required String title,
    required String artist,
    String? thumbnail,
    int? duration,
  }) async {
    final currentState = state;
    final playlists = currentState is PlaylistDialogLoaded
        ? currentState.playlists
        : <UserPlaylistEntity>[];

    emit(PlaylistDialogAddingSong(playlists: playlists));

    final result = await _addToPlaylistUseCase(
      playlistId: playlistId,
      videoId: videoId,
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      duration: duration,
    );

    result.fold(
      (error) => emit(PlaylistDialogError(_getErrorMessage(error))),
      (_) => emit(PlaylistDialogSongAdded()),
    );
  }

  Future<void> createPlaylist({
    required String name,
    String? description,
    String? thumbnail,
  }) async {
    final currentState = state;
    final playlists = currentState is PlaylistDialogLoaded
        ? currentState.playlists
        : <UserPlaylistEntity>[];

    emit(PlaylistDialogCreatingPlaylist(playlists: playlists));

    final result = await _createPlaylistUseCase(name: name);

    result.fold(
      (error) => emit(PlaylistDialogError(_getErrorMessage(error))),
      (playlist) => emit(PlaylistDialogPlaylistCreated(playlist)),
    );
  }

  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString();
    if (errorStr.contains('SocketException') ||
        errorStr.contains('Connection')) {
      return 'Sin conexión a internet';
    } else if (errorStr.contains('TimeoutException')) {
      return 'Tiempo de espera agotado';
    } else if (errorStr.contains('401')) {
      return 'Sesión expirada';
    } else if (errorStr.contains('403')) {
      return 'No tienes permiso para esta acción';
    } else if (errorStr.contains('404')) {
      return 'Playlist no encontrada';
    } else if (errorStr.contains('409')) {
      return 'La canción ya está en esta playlist';
    }
    return 'Error al cargar las playlists';
  }
}
