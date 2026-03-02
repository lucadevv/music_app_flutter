part of 'register_cubit.dart';

enum RegisterStatus { initial, loading, success, failure }

class RegisterState extends Equatable {
  final RegisterStatus status;
  final String? errorMessage;
  final RegisterResponse? responseEntity;

  const RegisterState({
    this.status = RegisterStatus.initial,
    this.errorMessage,
    this.responseEntity,
  });

  RegisterState copyWith({
    RegisterStatus? status,
    String? errorMessage,
    RegisterResponse? responseEntity,
  }) {
    return RegisterState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      responseEntity: responseEntity ?? this.responseEntity,
    );
  }

  factory RegisterState.initial() => const RegisterState(
    status: RegisterStatus.initial,
    errorMessage: null,
    responseEntity: null,
  );

  @override
  List<Object?> get props => [status, errorMessage, responseEntity];
}
