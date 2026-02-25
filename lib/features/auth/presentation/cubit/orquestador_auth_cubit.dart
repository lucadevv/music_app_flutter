import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../register/domain/entities/register_response.dart';
import '../../register/presentation/cubit/register_cubit.dart'
    show RegisterStatus, RegisterState;
import '../../login/presentation/cubit/login_cubit.dart'
    show LoginStatus, LoginState;

part 'orquestador_auth_state.dart';
part 'orquestador_auth_effect.dart';

/// Orquestador principal del flujo de autenticación
/// Coordina el flujo completo: Login/Registro -> Verificación de Email -> Dashboard
class OrquestadorAuthCubit extends Cubit<OrquestadorAuthState> {
  OrquestadorAuthCubit() : super(const OrquestadorAuthState());

  /// Estado del registro
  RegisterState _registerState = const RegisterState();

  /// Estado del login
  LoginState _loginState = const LoginState();

  RegisterState get registerState => _registerState;
  LoginState get loginState => _loginState;

  /// Actualiza el estado del registro
  void updateRegisterState(RegisterState state) {
    _registerState = state;
    emit(this.state.copyWith(registerState: state));
  }

  /// Actualiza el estado del login
  void updateLoginState(LoginState state) {
    _loginState = state;
    emit(this.state.copyWith(loginState: state));
  }

  /// Reinicia el estado de registro
  void resetRegisterState() {
    _registerState = const RegisterState();
    emit(state.copyWith(registerState: const RegisterState()));
  }

  /// Reinicia el estado de login
  void resetLoginState() {
    _loginState = const LoginState();
    emit(state.copyWith(loginState: const LoginState()));
  }

  /// Maneja el éxito del registro
  void handleRegisterSuccess(RegisterResponse response) {
    emit(
      state.copyWith(
        registerState: RegisterState(
          status: RegisterStatus.success,
          responseEntity: response,
        ),
        effect: response.user.isEmailVerified
            ? const NavigateToDashboardEffect()
            : const NavigateToEmailVerificationEffect(),
      ),
    );
  }

  /// Maneja el éxito del login
  void handleLoginSuccess(RegisterResponse response) {
    emit(
      state.copyWith(
        loginState: LoginState(
          status: LoginStatus.success,
          responseEntity: response,
        ),
        effect: response.user.isEmailVerified
            ? const NavigateToDashboardEffect()
            : const NavigateToEmailVerificationEffect(),
      ),
    );
  }

  /// Maneja errores en cualquier paso
  void handleError(String errorMessage) {
    emit(
      state.copyWith(
        hasError: true,
        errorMessage: errorMessage,
        effect: ShowErrorEffect(errorMessage),
      ),
    );
  }

  /// Limpia el effect después de procesarlo
  void clearEffect() {
    emit(state.copyWith(effect: null));
  }

  /// Reinicia todo el flujo
  void reset() {
    _registerState = const RegisterState();
    _loginState = const LoginState();
    emit(const OrquestadorAuthState());
  }
}
