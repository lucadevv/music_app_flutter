part of 'home_cubit.dart';

/// Estados del home
enum HomeStatus { initial, loading, success, failure }

/// Estado del cubit del home
class HomeState {
  final HomeStatus status;
  final String? errorMessage;
  final HomeResponse? homeResponse;

  const HomeState({
    this.status = HomeStatus.initial,
    this.errorMessage,
    this.homeResponse,
  });

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
    HomeResponse? homeResponse,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      homeResponse: homeResponse ?? this.homeResponse,
    );
  }
}
