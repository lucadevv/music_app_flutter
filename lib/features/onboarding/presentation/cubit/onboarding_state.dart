part of 'onboarding_cubit.dart';

/// Estados del onboarding
enum OnboardingStatus { initial, loading, success, failure }

/// Estado del cubit de onboarding
class OnboardingState {
  final OnboardingStatus status;
  final String? errorMessage;
  final bool isCompleted;

  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.errorMessage,
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    OnboardingStatus? status,
    String? errorMessage,
    bool? isCompleted,
    bool clearError = false,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
