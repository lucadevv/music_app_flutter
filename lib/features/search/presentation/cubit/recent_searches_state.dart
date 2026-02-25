part of 'recent_searches_cubit.dart';

enum RecentSearchesStatus {
  initial,
  loading,
  success,
  failure,
}

class RecentSearchesState extends Equatable {
  final RecentSearchesStatus status;
  final String? errorMessage;
  final List<RecentSearch> recentSearches;

  const RecentSearchesState({
    this.status = RecentSearchesStatus.initial,
    this.errorMessage,
    this.recentSearches = const [],
  });

  RecentSearchesState copyWith({
    RecentSearchesStatus? status,
    String? errorMessage,
    List<RecentSearch>? recentSearches,
  }) {
    return RecentSearchesState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }

  factory RecentSearchesState.initial() => const RecentSearchesState(
        status: RecentSearchesStatus.initial,
        errorMessage: null,
        recentSearches: [],
      );

  @override
  List<Object?> get props => [status, errorMessage, recentSearches];
}
