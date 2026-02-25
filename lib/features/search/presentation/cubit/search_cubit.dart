import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import '../../domain/entities/search_request.dart';
import '../../domain/entities/search_response.dart';
import '../../domain/use_cases/search_use_case.dart';

part 'search_state.dart';

/// Cubit para manejar el estado de la búsqueda
class SearchCubit extends Cubit<SearchState> with BaseBlocMixin {
  final SearchUseCase _searchUseCase;

  SearchCubit({required SearchUseCase searchUseCase})
    : _searchUseCase = searchUseCase,
      super(const SearchState());

  /// Realiza una búsqueda
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(
        state.copyWith(
          status: SearchStatus.initial,
          query: '',
          responseEntity: null,
          errorMessage: null,
        ),
      );
      return;
    }

    if (state.status == SearchStatus.loading) {
      return;
    }

    emit(
      state.copyWith(
        status: SearchStatus.loading,
        query: query,
        errorMessage: null,
      ),
    );

    final request = SearchRequest(query: query.trim(), filter: 'songs');
    final response = await _searchUseCase(request);

    // Verificar si el cubit está cerrado antes de emitir
    if (isClosed) {
      return;
    }

    response.fold(
      (failure) {
        // Verificar nuevamente antes de emitir
        if (isClosed) return;
        
        String errorMessage = getErrorMessage(failure);
        if (kDebugMode) {
          debugPrint("SearchCubit: errorMessage $errorMessage");
        }
        emit(
          state.copyWith(
            status: SearchStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (responseEntity) {
        // Verificar nuevamente antes de emitir
        if (isClosed) return;
        
        emit(
          state.copyWith(
            status: SearchStatus.success,
            responseEntity: responseEntity,
            errorMessage: null,
          ),
        );
      },
    );
  }

  void reset() {
    emit(const SearchState());
  }
}
