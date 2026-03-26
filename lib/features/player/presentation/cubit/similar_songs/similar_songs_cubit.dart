import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/player/domain/entities/radio_track_entity.dart';
import 'package:music_app/features/player/domain/usecases/get_radio_playlist_usecase.dart';

part 'similar_songs_state.dart';

class SimilarSongsCubit extends Cubit<SimilarSongsState> {
  final GetRadioPlaylistUseCase _getRadioPlaylistUseCase;

  SimilarSongsCubit(this._getRadioPlaylistUseCase)
    : super(const SimilarSongsState());

  Future<void> loadSimilarSongs(String videoId) async {
    if (videoId.isEmpty) {
      if (isClosed) return;
      emit(state.copyWith(status: SimilarSongsStatus.success, tracks: []));
      return;
    }

    emit(state.copyWith(status: SimilarSongsStatus.loading, error: null));

    try {
      final result = await _getRadioPlaylistUseCase(videoId, limit: 10);

      if (isClosed) return;

      result.fold(
        (error) {
          emit(
            state.copyWith(
              status: SimilarSongsStatus.failure,
              error: error.message,
              tracks: [],
            ),
          );
        },
        (tracks) {
          emit(
            state.copyWith(status: SimilarSongsStatus.success, tracks: tracks),
          );
        },
      );
    } catch (e) {
      if (isClosed) return;

      final errorString = e.toString().toLowerCase();
      final isIgnorableError =
          errorString.contains('cancelled') ||
          errorString.contains('interrupted') ||
          errorString.contains('loading interrupted') ||
          errorString.contains('connection') &&
              errorString.contains('closed') ||
          errorString.contains('socketexception') ||
          errorString.contains('timeout') ||
          errorString.contains('resetear player') ||
          errorString.contains('bad response') ||
          errorString.contains('500') ||
          errorString.contains('502') ||
          errorString.contains('503') ||
          errorString.contains('dioexception');

      if (isIgnorableError) {
        // No mostrar error, simplemente cargar silencio
        emit(state.copyWith(status: SimilarSongsStatus.success, tracks: []));
        return;
      }

      emit(
        state.copyWith(status: SimilarSongsStatus.failure, error: e.toString()),
      );
    }
  }
}
