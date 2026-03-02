import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/home/domain/entities/mood_genre.dart';
import 'package:music_app/features/search/domain/usecases/get_categories_usecase.dart';

part 'categories_state.dart';

/// Cubit para gestionar las categorías (moods/genres) en la pantalla de búsqueda
class CategoriesCubit extends Cubit<CategoriesState> with BaseBlocMixin {
  final GetCategoriesUseCase _getCategoriesUseCase;

  CategoriesCubit(this._getCategoriesUseCase) : super(const CategoriesState.initial());

  /// Carga las categorías desde el endpoint /music/explore
  Future<void> loadCategories() async {
    if (state.status == CategoriesStatus.loading) return;

    emit(state.copyWith(status: CategoriesStatus.loading));

    final result = await _getCategoriesUseCase();

    result.fold(
      (error) {
        emit(
          state.copyWith(
            status: CategoriesStatus.failure,
            errorMessage: getErrorMessage(error),
          ),
        );
      },
      (categories) {
        emit(
          state.copyWith(
            status: CategoriesStatus.success,
            categories: categories,
          ),
        );
      },
    );
  }

  /// Reinicia el estado
  void reset() {
    emit(const CategoriesState.initial());
  }
}
