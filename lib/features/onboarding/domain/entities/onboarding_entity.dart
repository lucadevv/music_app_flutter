import 'package:equatable/equatable.dart';

/// Entity representing onboarding state.
class OnboardingEntity extends Equatable {
  final bool isCompleted;
  final int currentPage;
  final List<OnboardingPageEntity> pages;

  const OnboardingEntity({
    this.isCompleted = false,
    this.currentPage = 0,
    this.pages = const [],
  });

  OnboardingEntity copyWith({
    bool? isCompleted,
    int? currentPage,
    List<OnboardingPageEntity>? pages,
  }) {
    return OnboardingEntity(
      isCompleted: isCompleted ?? this.isCompleted,
      currentPage: currentPage ?? this.currentPage,
      pages: pages ?? this.pages,
    );
  }

  @override
  List<Object?> get props => [isCompleted, currentPage, pages];
}

/// Entity representing a single onboarding page.
class OnboardingPageEntity extends Equatable {
  final String title;
  final String description;
  final String? imageUrl;

  const OnboardingPageEntity({
    required this.title,
    required this.description,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [title, description, imageUrl];
}
