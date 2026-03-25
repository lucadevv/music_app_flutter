import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/splash/domain/entities/splash_entity.dart';
import 'package:music_app/features/splash/domain/use_cases/initialize_app_use_case.dart';

part 'splash_state.dart';

/// Cubit para manejar el estado del splash screen.
///
/// Clean Architecture: Capa de presentación - maneja el estado de la UI
///
/// Patrón aplicado:
/// - UI → SplashCubit → InitializeAppUseCase → SplashRepository → SplashDataSource
class SplashCubit extends Cubit<SplashState> with BaseBlocMixin {
  final InitializeAppUseCase _initializeAppUseCase;

  SplashCubit(this._initializeAppUseCase) : super(const SplashState());

  /// Inicializa la app y determina la ruta de redirección
  Future<void> initializeApp() async {
    if (state.status == SplashStatus.loading) {
      return;
    }

    emit(state.copyWith(status: SplashStatus.loading, clearError: true));

    final result = await _initializeAppUseCase();

    if (isClosed) return;

    result.fold(
      (error) {
        final String errorMessage = getErrorMessage(error);
        emit(
          state.copyWith(
            status: SplashStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (splashEntity) {
        emit(
          state.copyWith(
            status: SplashStatus.success,
            splashEntity: splashEntity,
            redirectRoute: splashEntity.redirectRoute,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Reinicia el estado
  void reset() {
    emit(const SplashState());
  }
}
