import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/home/data/models/mood_genre_model.dart';
import 'package:music_app/features/home/domain/entities/mood_genre.dart';

part 'categories_state.dart';

/// Cubit para gestionar las categorías (moods/genres) en la pantalla de búsqueda
class CategoriesCubit extends Cubit<CategoriesState> with BaseBlocMixin {
  final ApiServices _apiServices;

  CategoriesCubit(this._apiServices) : super(const CategoriesState.initial());

  /// Carga las categorías desde el endpoint /music/explore
  Future<void> loadCategories() async {
    if (state.status == CategoriesStatus.loading) return;

    emit(state.copyWith(status: CategoriesStatus.loading));

    try {
      const endpoint = '/music/explore';
      final response = await _apiServices.get(endpoint);

      final responseData = response is Response ? response.data : response;

      if (responseData is Map<String, dynamic>) {
        final moodsGenresList = responseData['moods_genres'] as List<dynamic>? ?? [];

        // Filtrar solo categorías con params válido (no vacío)
        final categories = moodsGenresList
            .map((json) => MoodGenreModel.fromJson(json as Map<String, dynamic>))
            .where((category) => category.params.isNotEmpty)
            .toList();

        emit(state.copyWith(
          status: CategoriesStatus.success,
          categories: categories,
        ));
      } else {
        emit(state.copyWith(
          status: CategoriesStatus.failure,
          errorMessage: 'Respuesta del servidor en formato incorrecto',
        ));
      }
    } catch (e) {
      final appException = e is AppException 
          ? e 
          : UnknownException(e.toString());
      
      emit(state.copyWith(
        status: CategoriesStatus.failure,
        errorMessage: getErrorMessage(appException),
      ));
    }
  }

  /// Reinicia el estado
  void reset() {
    emit(const CategoriesState.initial());
  }
}
