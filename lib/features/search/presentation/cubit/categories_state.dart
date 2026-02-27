part of 'categories_cubit.dart';

/// Estados del CategoriesCubit
enum CategoriesStatus { initial, loading, success, failure }

class CategoriesState extends Equatable {
  final CategoriesStatus status;
  final List<MoodGenre> categories;
  final String? errorMessage;

  const CategoriesState({
    this.status = CategoriesStatus.initial,
    this.categories = const [],
    this.errorMessage,
  });

  const CategoriesState.initial() : this();

  CategoriesState copyWith({
    CategoriesStatus? status,
    List<MoodGenre>? categories,
    String? errorMessage,
    bool clearError = false,
  }) {
    return CategoriesState(
      status: status ?? this.status,
      categories: categories ?? this.categories,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, categories, errorMessage];
}
