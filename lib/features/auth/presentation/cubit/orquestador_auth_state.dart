part of 'orquestador_auth_cubit.dart';

/// Effects para navegación del flujo de autenticación
sealed class OrquestadorAuthEffect extends Equatable {
  const OrquestadorAuthEffect();

  @override
  List<Object?> get props => [];
}

class NavigateToDashboardEffect extends OrquestadorAuthEffect {
  const NavigateToDashboardEffect();
}

class NavigateToEmailVerificationEffect extends OrquestadorAuthEffect {
  const NavigateToEmailVerificationEffect();
}

class ShowErrorEffect extends OrquestadorAuthEffect {
  final String message;

  const ShowErrorEffect(this.message);

  @override
  List<Object?> get props => [message];
}

class OrquestadorAuthState extends Equatable {
  final RegisterState registerState;
  final LoginState loginState;
  final bool hasError;
  final String? errorMessage;
  final OrquestadorAuthEffect? effect;

  const OrquestadorAuthState({
    this.registerState = const RegisterState(),
    this.loginState = const LoginState(),
    this.hasError = false,
    this.errorMessage,
    this.effect,
  });

  OrquestadorAuthState copyWith({
    RegisterState? registerState,
    LoginState? loginState,
    bool? hasError,
    String? errorMessage,
    OrquestadorAuthEffect? effect,
  }) {
    return OrquestadorAuthState(
      registerState: registerState ?? this.registerState,
      loginState: loginState ?? this.loginState,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      effect: effect,
    );
  }

  @override
  List<Object?> get props => [
        registerState,
        loginState,
        hasError,
        errorMessage,
        effect,
      ];
}
