import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/relax/domain/use_cases/get_relax_playlists_use_case.dart';
import 'package:music_app/features/relax/presentation/cubit/relax_state.dart';

class RelaxCubit extends Cubit<RelaxState> {
  final GetRelaxPlaylistsUseCase _getRelaxPlaylistsUseCase;

  RelaxCubit({required GetRelaxPlaylistsUseCase getRelaxPlaylistsUseCase})
    : _getRelaxPlaylistsUseCase = getRelaxPlaylistsUseCase,
      super(const RelaxState());

  Future<void> loadRelaxPlaylists() async {
    emit(state.copyWith(status: RelaxStatus.loading));

    final result = await _getRelaxPlaylistsUseCase();

    result.fold(
      (error) => emit(
        state.copyWith(
          status: RelaxStatus.failure,
          errorMessage: error.toString(),
        ),
      ),
      (playlists) => emit(
        state.copyWith(status: RelaxStatus.success, playlists: playlists),
      ),
    );
  }

  void selectCategory(int index) {
    emit(state.copyWith(selectedCategoryIndex: index));
  }
}
