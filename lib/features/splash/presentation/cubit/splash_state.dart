part of 'splash_cubit.dart';

/// Estados del splash screen
enum SplashStatus { initial, loading, success, failure }

/// Estado del cubit de splash
class SplashState {
  final SplashStatus status;
  final String? errorMessage;
  final SplashEntity? splashEntity;
  final String? redirectRoute;

  const SplashState({
    this.status = SplashStatus.initial,
    this.errorMessage,
    this.splashEntity,
    this.redirectRoute,
  });

  SplashState copyWith({
    SplashStatus? status,
    String? errorMessage,
    SplashEntity? splashEntity,
    String? redirectRoute,
    bool clearError = false,
  }) {
    return SplashState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      splashEntity: splashEntity ?? this.splashEntity,
      redirectRoute: redirectRoute ?? this.redirectRoute,
    );
  }
}
