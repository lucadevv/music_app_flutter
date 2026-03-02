import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/main.dart';
import '../../domain/entities/register_request.dart';
import '../../domain/entities/register_response.dart';
import '../../domain/use_cases/register_use_case.dart';

part 'register_state.dart';

/// Cubit para manejar el estado del registro
class RegisterCubit extends Cubit<RegisterState> with BaseBlocMixin {
  final RegisterUseCase _registerUseCase;

  RegisterCubit({required RegisterUseCase registerUseCase})
    : _registerUseCase = registerUseCase,
      super(const RegisterState());

  /// Registra un nuevo usuario
  Future<void> register(RegisterRequest entity) async {
    if (state.status == RegisterStatus.loading) {
      return;
    }

    emit(state.copyWith(status: RegisterStatus.loading));

    final response = await _registerUseCase(entity);

    await response.fold(
      (failure) {
        final String errorMessage = getErrorMessage(failure);
        emit(
          state.copyWith(
            status: RegisterStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (responseEntity) async {
        try {
          final authManager = await getIt.getAsync<AuthManager>();
          await authManager.login(
            responseEntity.accessToken,
            responseEntity.refreshToken,
            isEmailVerified: responseEntity.user.isEmailVerified,
            email: responseEntity.user.email,
          );

          // Verificar que se guardó correctamente
          final savedIsEmailVerified = await authManager.isEmailVerified();
          if (kDebugMode) {
            debugPrint(
              'RegisterCubit: Tokens guardados. isEmailVerified guardado: $savedIsEmailVerified (esperado: ${responseEntity.user.isEmailVerified})',
            );
          }

          emit(
            state.copyWith(
              status: RegisterStatus.success,
              responseEntity: responseEntity,
              errorMessage: null,
            ),
          );
        } catch (e) {
          if (kDebugMode) {
            debugPrint('RegisterCubit: Error guardando tokens: $e');
          }
          emit(
            state.copyWith(
              status: RegisterStatus.failure,
              errorMessage: 'Error al guardar los tokens: ${e.toString()}',
            ),
          );
        }
      },
    );
  }

  void reset() {
    emit(const RegisterState());
  }
}
