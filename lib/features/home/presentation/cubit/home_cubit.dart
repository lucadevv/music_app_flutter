import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/home/domain/entities/home_response.dart';
import 'package:music_app/features/home/domain/use_cases/get_home_use_case.dart';

part 'home_state.dart';

/// Cubit para manejar el estado del home
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Gestionar el estado y lógica del home
///
/// Clean Architecture: Capa de presentación - maneja el estado de la UI
class HomeCubit extends Cubit<HomeState> with BaseBlocMixin {
  final GetHomeUseCase _getHomeUseCase;

  HomeCubit(this._getHomeUseCase) : super(const HomeState());

  /// Carga los datos del home
  Future<void> loadHome() async {
    if (state.status == HomeStatus.loading) {
      return;
    }

    emit(state.copyWith(status: HomeStatus.loading, clearError: true));

    final result = await _getHomeUseCase();

    if (isClosed) return;

    result.fold(
      (error) {
        String errorMessage = getErrorMessage(error);
        emit(
          state.copyWith(
            status: HomeStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (homeResponse) {
        emit(
          state.copyWith(
            status: HomeStatus.success,
            homeResponse: homeResponse,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Reinicia el estado
  void reset() {
    emit(const HomeState());
  }
}
