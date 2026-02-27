import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';
import 'package:music_app/core/managers/auth/auth_manager.dart';
import 'package:music_app/features/auth/register/domain/entities/register_response.dart';
import 'package:music_app/main.dart';

import '../../domain/entities/login_request.dart';
import '../../domain/use_cases/login_use_case.dart';
import '../../domain/use_cases/oauth_sign_in_use_case.dart';

part 'login_state.dart';

/// Cubit para manejar el estado del login
class LoginCubit extends Cubit<LoginState> with BaseBlocMixin {
  final LoginUseCase _loginUseCase;
  final GoogleSignInUseCase _googleSignInUseCase;
  final AppleSignInUseCase _appleSignInUseCase;

  LoginCubit({
    required LoginUseCase loginUseCase,
    required GoogleSignInUseCase googleSignInUseCase,
    required AppleSignInUseCase appleSignInUseCase,
  })  : _loginUseCase = loginUseCase,
        _googleSignInUseCase = googleSignInUseCase,
        _appleSignInUseCase = appleSignInUseCase,
        super(const LoginState());

  /// Inicia sesión con email y contraseña
  Future<void> login(LoginRequest entity) async {
    if (state.status == LoginStatus.loading) {
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    final response = await _loginUseCase(entity);

    await response.fold(
      (failure) {
        String errorMessage = getErrorMessage(failure);
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (responseEntity) async {
        await _handleAuthSuccess(responseEntity);
      },
    );
  }

  /// Inicia sesión con Google
  Future<void> signInWithGoogle() async {
    if (state.status == LoginStatus.loading) {
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    final response = await _googleSignInUseCase();

    if (isClosed) return;

    response.fold(
      (failure) {
        String errorMessage = getErrorMessage(failure);
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (oauthResponse) async {
        // Convertir OAuthResponse a RegisterResponse para compatibilidad
        final responseEntity = RegisterResponse(
          accessToken: oauthResponse.accessToken,
          refreshToken: oauthResponse.refreshToken,
          expiresIn: oauthResponse.expiresIn,
          user: oauthResponse.user,
        );
        await _handleAuthSuccess(responseEntity);
      },
    );
  }

  /// Inicia sesión con Apple
  Future<void> signInWithApple() async {
    if (state.status == LoginStatus.loading) {
      return;
    }

    emit(state.copyWith(status: LoginStatus.loading));

    final response = await _appleSignInUseCase();

    if (isClosed) return;

    response.fold(
      (failure) {
        String errorMessage = getErrorMessage(failure);
        emit(
          state.copyWith(
            status: LoginStatus.failure,
            errorMessage: errorMessage,
          ),
        );
      },
      (oauthResponse) async {
        // Convertir OAuthResponse a RegisterResponse para compatibilidad
        final responseEntity = RegisterResponse(
          accessToken: oauthResponse.accessToken,
          refreshToken: oauthResponse.refreshToken,
          expiresIn: oauthResponse.expiresIn,
          user: oauthResponse.user,
        );
        await _handleAuthSuccess(responseEntity);
      },
    );
  }

  /// Maneja el éxito de la autenticación (común para email/password y OAuth)
  Future<void> _handleAuthSuccess(RegisterResponse responseEntity) async {
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
      debugPrint(
        'LoginCubit: Tokens guardados. isEmailVerified guardado: $savedIsEmailVerified (esperado: ${responseEntity.user.isEmailVerified})',
      );

      emit(
        state.copyWith(
          status: LoginStatus.success,
          responseEntity: responseEntity,
          errorMessage: null,
        ),
      );
    } catch (e) {
      debugPrint('LoginCubit: Error guardando tokens: $e');
      emit(
        state.copyWith(
          status: LoginStatus.failure,
          errorMessage: 'Error al guardar los tokens: ${e.toString()}',
        ),
      );
    }
  }

  void reset() {
    emit(const LoginState());
  }
}
