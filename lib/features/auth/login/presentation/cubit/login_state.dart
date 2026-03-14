part of 'login_cubit.dart';

enum LoginStatus { initial, loading, success, failure }

enum OAuthProviderType { google, apple }

class LoginState extends Equatable {
  final LoginStatus status;
  final String? errorMessage;
  final RegisterResponse? responseEntity;
  final OAuthProviderType? loadingProvider;

  const LoginState({
    this.status = LoginStatus.initial,
    this.errorMessage,
    this.responseEntity,
    this.loadingProvider,
  });

  bool isLoadingFor(OAuthProviderType provider) {
    return status == LoginStatus.loading && loadingProvider == provider;
  }

  LoginState copyWith({
    LoginStatus? status,
    String? errorMessage,
    RegisterResponse? responseEntity,
    OAuthProviderType? loadingProvider,
    bool clearLoadingProvider = false,
  }) {
    return LoginState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      responseEntity: responseEntity ?? this.responseEntity,
      loadingProvider: clearLoadingProvider ? null : (loadingProvider ?? this.loadingProvider),
    );
  }

  factory LoginState.initial() => const LoginState(
    status: LoginStatus.initial,
    errorMessage: null,
    responseEntity: null,
    loadingProvider: null,
  );

  @override
  List<Object?> get props => [status, errorMessage, responseEntity, loadingProvider];
}
