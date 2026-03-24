import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/library/library_service.dart';

part 'playlist_dialog_state.dart';

class PlaylistDialogCubit extends Cubit<PlaylistDialogState> {
  final LibraryService _libraryService;

  PlaylistDialogCubit(this._libraryService) : super(PlaylistDialogInitial());

  Future<void> loadPlaylists() async {
    emit(PlaylistDialogLoading());

    try {
      final response = await _libraryService.getUserPlaylists();
      emit(PlaylistDialogLoaded(playlists: response.data));
    } catch (e) {
      emit(PlaylistDialogError(_getErrorMessage(e)));
    }
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
        : <UserPlaylist>[];

    emit(PlaylistDialogAddingSong(playlists: playlists));

    try {
      await _libraryService.addSongToUserPlaylist(
        playlistId,
        videoId: videoId,
        title: title,
        artist: artist,
        thumbnail: thumbnail,
        duration: duration,
      );
      emit(PlaylistDialogSongAdded());
    } catch (e) {
      emit(PlaylistDialogError(_getErrorMessage(e)));
    }
  }

  Future<void> createPlaylist({
    required String name,
    String? description,
    String? thumbnail,
  }) async {
    final currentState = state;
    final playlists = currentState is PlaylistDialogLoaded
        ? currentState.playlists
        : <UserPlaylist>[];

    emit(PlaylistDialogCreatingPlaylist(playlists: playlists));

    try {
      final playlist = await _libraryService.createUserPlaylist(
        name: name,
        description: description,
        thumbnail: thumbnail,
      );
      emit(PlaylistDialogPlaylistCreated(playlist));
    } catch (e) {
      emit(PlaylistDialogError(_getErrorMessage(e)));
    }
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
