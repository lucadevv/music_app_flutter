import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import '../../domain/entities/recent_search.dart';
import '../../domain/use_cases/get_recent_searches_use_case.dart';

part 'recent_searches_state.dart';

/// Cubit para manejar el estado de las búsquedas recientes
class RecentSearchesCubit extends Cubit<RecentSearchesState> with BaseBlocMixin {
  final GetRecentSearchesUseCase _getRecentSearchesUseCase;

  RecentSearchesCubit({required GetRecentSearchesUseCase getRecentSearchesUseCase})
      : _getRecentSearchesUseCase = getRecentSearchesUseCase,
        super(const RecentSearchesState());

  /// Obtiene las búsquedas recientes
  Future<void> getRecentSearches({int limit = 10}) async {
    if (state.status == RecentSearchesStatus.loading) {
      return;
    }

    // Verificar si el cubit está cerrado antes de emitir
    if (isClosed) {
      return;
    }

    emit(state.copyWith(status: RecentSearchesStatus.loading));

    final response = await _getRecentSearchesUseCase(limit: limit);

    // Verificar nuevamente antes de emitir
    if (isClosed) {
      return;
    }

    response.fold(
      (failure) {
        if (isClosed) return;
        
        String errorMessage = getErrorMessage(failure);
        if (kDebugMode) {
          debugPrint("RecentSearchesCubit: errorMessage $errorMessage");
        }
        emit(
          state.copyWith(
            status: RecentSearchesStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (recentSearches) {
        if (isClosed) return;
        
        emit(
          state.copyWith(
            status: RecentSearchesStatus.success,
            recentSearches: recentSearches,
            errorMessage: null,
          ),
        );
      },
    );
  }

  void reset() {
    emit(const RecentSearchesState());
  }
}
