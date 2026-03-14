// ignore_for_file: deprecated_member_use_from_same_package
import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/search/domain/entities/song.dart';
import 'package:music_app/features/search/domain/use_cases/update_selected_song_use_case.dart';

import '../cubit/recent_searches_cubit.dart'
    show RecentSearchesCubit, RecentSearchesState;
import '../cubit/search_cubit.dart' show SearchCubit, SearchStatus, SearchState;

part 'orquestador_search_effect.dart';
part 'orquestador_search_state.dart';

/// Orquestador principal del flujo de búsqueda
/// Coordina el flujo completo de búsqueda
class OrquestadorSearchCubit extends Cubit<OrquestadorSearchState> {
  final SearchCubit _searchCubit;
  final RecentSearchesCubit _recentSearchesCubit;
  final UpdateSelectedSongUseCase _updateSelectedSongUseCase;

  StreamSubscription? _searchSubscription;
  StreamSubscription? _recentSearchesSubscription;

  OrquestadorSearchCubit({
    required SearchCubit searchCubit,
    required RecentSearchesCubit recentSearchesCubit,
    required UpdateSelectedSongUseCase updateSelectedSongUseCase,
  }) : _searchCubit = searchCubit,
       _recentSearchesCubit = recentSearchesCubit,
       _updateSelectedSongUseCase = updateSelectedSongUseCase,
       super(OrquestadorSearchState.initial()) {
    _startListening();
  }

  void saveSelectedSong(Song song, String query) {
     _updateSelectedSongUseCase(
      query: query,
      videoId: song.videoId,
      song: song,
    );
     // Recargar lista de busquedas luego de insertar
     _recentSearchesCubit.getRecentSearches();
  }

  void _startListening() {
    // Escuchar cambios del SearchCubit
    _searchSubscription = _searchCubit.stream.listen(_updateSearchState);

    // Escuchar cambios del RecentSearchesCubit
    _recentSearchesSubscription = _recentSearchesCubit.stream.listen(
      _updateRecentSearchesState,
    );
  }

  void _updateSearchState(SearchState state) {
    // Si hay un error, emitir el effect correspondiente
    if (state.status == SearchStatus.failure) {
      emit(
        this.state.copyWith(
          searchState: state,
          hasError: true,
          errorMessage: state.errorMessage,
          effect: ShowErrorEffect(state.errorMessage ?? 'Error en la búsqueda'),
        ),
      );
    } else {
      // Limpiar errores si hay éxito o está en otro estado
      emit(
        this.state.copyWith(
          searchState: state,
          hasError: false,
          errorMessage: null,
        ),
      );
    }
  }

  void _updateRecentSearchesState(RecentSearchesState state) {
    emit(this.state.copyWith(recentSearchesState: state));
  }

  /// Actualiza el estado de la búsqueda manualmente (para compatibilidad)
  void updateSearchState(SearchState state) {
    _updateSearchState(state);
  }

  /// Actualiza el estado de las búsquedas recientes manualmente (para compatibilidad)
  void updateRecentSearchesState(RecentSearchesState state) {
    _updateRecentSearchesState(state);
  }

  /// Reinicia el estado de búsqueda
  void resetSearchState() {
    _searchCubit.reset();
    emit(state.copyWith(searchState: const SearchState()));
  }

  /// Reinicia el estado de búsquedas recientes
  void resetRecentSearchesState() {
    _recentSearchesCubit.reset();
    emit(state.copyWith(recentSearchesState: const RecentSearchesState()));
  }

  /// Limpia el effect después de procesarlo
  void clearEffect() {
    emit(state.copyWith(effect: null));
  }

  /// Reinicia todo el flujo
  void reset() {
    _searchCubit.reset();
    _recentSearchesCubit.reset();
    emit(OrquestadorSearchState.initial());
  }

  @override
  Future<void> close() {
    _searchSubscription?.cancel();
    _recentSearchesSubscription?.cancel();
    return super.close();
  }
}
