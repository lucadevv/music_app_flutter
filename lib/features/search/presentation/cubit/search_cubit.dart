import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import '../../domain/entities/search_request.dart';
import '../../domain/entities/search_response.dart';
import '../../domain/use_cases/search_use_case.dart';

part 'search_state.dart';

/// Cubit para manejar el estado de la búsqueda
class SearchCubit extends Cubit<SearchState> with BaseBlocMixin {
  final SearchUseCase _searchUseCase;
  Timer? _debounceTimer;

  SearchCubit({required SearchUseCase searchUseCase})
      : _searchUseCase = searchUseCase,
        super(const SearchState());

  /// Realiza una búsqueda con debounce automático (800ms)
  /// Este método debe llamarse desde la UI cada vez que cambia el texto
  void searchWithDebounce(String query) {
    // Cancelar el timer anterior
    _debounceTimer?.cancel();

    // Si el campo está vacío, resetear inmediatamente
    if (query.trim().isEmpty) {
      search('');
      return;
    }

    // Crear un nuevo timer con debounce de 800ms
    _debounceTimer = Timer(const Duration(milliseconds: 800), () {
      if (!isClosed) {
        search(query);
      }
    });
  }

  /// Cancela el debounce actual (útil cuando se sale de la pantalla)
  void cancelDebounce() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Realiza una búsqueda
  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      emit(
        SearchState.initial().copyWith(query: ''),
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
        currentPage: 0,
        hasMore: true,
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

        final String errorMessage = getErrorMessage(failure);
        if (kDebugMode) {
          debugPrint('SearchCubit: errorMessage $errorMessage');
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
            hasMore: responseEntity.results.length >= 20, // Si devuelve 20, hay más
            currentPage: 1,
          ),
        );
      },
    );
  }

  /// Cargar más resultados (paginación)
  Future<void> loadMore() async {
    if (state.status == SearchStatus.loadingMore || 
        !state.hasMore ||
        state.query.isEmpty) {
      return;
    }

    emit(state.copyWith(status: SearchStatus.loadingMore));

    final request = SearchRequest(
      query: state.query.trim(),
      filter: 'songs',
      startIndex: state.currentPage * 20,
    );
    
    final response = await _searchUseCase(request);

    if (isClosed) return;

    response.fold(
      (failure) {
        if (isClosed) return;
        
        final String errorMessage = getErrorMessage(failure);
        emit(
          state.copyWith(
            status: SearchStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (responseEntity) {
        if (isClosed) return;

        // Combinar resultados anteriores con nuevos
        final currentResults = state.responseEntity?.results ?? [];
        final newResults = responseEntity.results;
        final allResults = [...currentResults, ...newResults];

        emit(
          state.copyWith(
            status: SearchStatus.success,
            responseEntity: SearchResponse(
              results: allResults,
              query: state.query,
              albums: [...state.responseEntity?.albums ?? [], ...responseEntity.albums],
              artists: [...state.responseEntity?.artists ?? [], ...responseEntity.artists],
            ),
            hasMore: newResults.length >= 20,
            currentPage: state.currentPage + 1,
          ),
        );
      },
    );
  }

  void reset() {
    _debounceTimer?.cancel();
    emit(SearchState.initial());
  }

  @override
  Future<void> close() {
    _debounceTimer?.cancel();
    return super.close();
  }
}
