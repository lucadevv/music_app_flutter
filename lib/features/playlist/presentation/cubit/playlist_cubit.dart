import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_state.dart';
import '../../domain/use_cases/get_playlist_use_case.dart';

/// Cubit para manejar el estado de la playlist
class PlaylistCubit extends Cubit<PlaylistState> with BaseBlocMixin {
  final GetPlaylistUseCase _getPlaylistUseCase;

  PlaylistCubit({required GetPlaylistUseCase getPlaylistUseCase})
    : _getPlaylistUseCase = getPlaylistUseCase,
      super(const PlaylistState());

  /// Carga los datos de una playlist
  Future<void> loadPlaylist(String id) async {
    if (state.status == PlaylistStatus.loading) {
      return;
    }

    // Validar que el ID no esté vacío
    if (id.isEmpty) {
      emit(
        state.copyWith(
          status: PlaylistStatus.failure,
          errorMessage: 'El ID de la playlist no puede estar vacío',
        ),
      );
      return;
    }

    emit(state.copyWith(status: PlaylistStatus.loading, errorMessage: null));

    final result = await _getPlaylistUseCase(id);

    result.fold(
      (failure) {
        String errorMessage = getErrorMessage(failure);
        emit(
          state.copyWith(
            status: PlaylistStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (response) {
        emit(
          state.copyWith(
            status: PlaylistStatus.success,
            response: response,
            errorMessage: null,
          ),
        );
      },
    );
  }

  /// Reinicia el estado del cubit
  void reset() {
    emit(const PlaylistState());
  }
}
