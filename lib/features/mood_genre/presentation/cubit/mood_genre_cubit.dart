import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import '../../domain/entities/mood_playlists_response.dart';
import '../../domain/use_cases/get_mood_playlists_use_case.dart';

part 'mood_genre_state.dart';

/// Cubit para gestionar el estado de mood/genre
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Gestionar el estado de las playlists de mood/genre
class MoodGenreCubit extends Cubit<MoodGenreState> with BaseBlocMixin {
  final GetMoodPlaylistsUseCase _getMoodPlaylistsUseCase;

  MoodGenreCubit(this._getMoodPlaylistsUseCase)
      : super(const MoodGenreState());

  /// Carga las playlists de un mood/genre
  Future<void> loadMoodPlaylists(String params) async {
    if (state.status == MoodGenreStatus.loading) {
      return;
    }

    emit(state.copyWith(
      status: MoodGenreStatus.loading,
      errorMessage: null,
    ));

    final result = await _getMoodPlaylistsUseCase(params);

    if (isClosed) return;

    result.fold(
      (failure) {
        final errorMessage = getErrorMessage(failure);
        emit(state.copyWith(
          status: MoodGenreStatus.failure,
          errorMessage: errorMessage,
        ));
      },
      (response) {
        emit(state.copyWith(
          status: MoodGenreStatus.success,
          response: response,
          errorMessage: null,
        ));
      },
    );
  }

  /// Reinicia el estado
  void reset() {
    emit(const MoodGenreState());
  }
}
