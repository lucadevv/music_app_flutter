import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/features/onboarding/domain/use_cases/check_onboarding_completed_use_case.dart';
import 'package:music_app/features/onboarding/domain/use_cases/complete_onboarding_use_case.dart';

part 'onboarding_state.dart';

/// Cubit para manejar el estado del onboarding.
///
/// Clean Architecture: Capa de presentación - maneja el estado de la UI
///
/// Patron aplicado:
/// - UI → OnboardingCubit → UseCase → Repository → DataSource → API
class OnboardingCubit extends Cubit<OnboardingState> with BaseBlocMixin {
  final CheckOnboardingCompletedUseCase _checkOnboardingCompletedUseCase;
  final CompleteOnboardingUseCase _completeOnboardingUseCase;

  OnboardingCubit(
    this._checkOnboardingCompletedUseCase,
    this._completeOnboardingUseCase,
  ) : super(const OnboardingState());

  /// Verifica si el onboarding ya fue completado
  Future<void> checkOnboardingCompleted() async {
    if (state.status == OnboardingStatus.loading) {
      return;
    }

    emit(state.copyWith(status: OnboardingStatus.loading, clearError: true));

    final result = await _checkOnboardingCompletedUseCase();

    if (isClosed) return;

    result.fold(
      (error) {
        final String errorMessage = getErrorMessage(error);
        emit(
          state.copyWith(
            status: OnboardingStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (isCompleted) {
        emit(
          state.copyWith(
            status: OnboardingStatus.success,
            isCompleted: isCompleted,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Marca el onboarding como completado
  Future<void> completeOnboarding() async {
    if (state.status == OnboardingStatus.loading) {
      return;
    }

    emit(state.copyWith(status: OnboardingStatus.loading, clearError: true));

    final result = await _completeOnboardingUseCase();

    if (isClosed) return;

    result.fold(
      (error) {
        final String errorMessage = getErrorMessage(error);
        emit(
          state.copyWith(
            status: OnboardingStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (_) {
        emit(
          state.copyWith(
            status: OnboardingStatus.success,
            isCompleted: true,
            clearError: true,
          ),
        );
      },
    );
  }

  /// Reinicia el estado
  void reset() {
    emit(const OnboardingState());
  }
}
