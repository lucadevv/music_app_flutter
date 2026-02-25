part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

class LoginState extends Equatable {
  final LoginStatus status;
  final String? errorMessage;
  final RegisterResponse? responseEntity;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.responseEntity,
  });

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    RegisterResponse? responseEntity,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      responseEntity: responseEntity ?? this.responseEntity,
    );
  }

  factory LoginState.initial() => const LoginState(
    status: LoginStatus.initial,
    errorMessage: null,
    responseEntity: null,
  );

  @override
  List<Object?> get props => [status, errorMessage, responseEntity];
}
