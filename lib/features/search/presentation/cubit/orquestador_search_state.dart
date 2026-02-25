part of 'orquestador_search_cubit.dart';

/// Effects para el flujo de búsqueda
sealed class OrquestadorSearchEffect extends Equatable {
  const OrquestadorSearchEffect();

  @override
  List<Object?> get props => [];
}

class ShowErrorEffect extends OrquestadorSearchEffect {
  final String message;

  const ShowErrorEffect(this.message);

  @override
  List<Object?> get props => [message];
}

class OrquestadorSearchState extends Equatable {
  final SearchState searchState;
  final RecentSearchesState recentSearchesState;
  final bool hasError;
  final String? errorMessage;
  final OrquestadorSearchEffect? effect;

  const OrquestadorSearchState({
    required this.searchState,
    required this.recentSearchesState,
    this.hasError = false,
    this.errorMessage,
    this.effect,
  });

  OrquestadorSearchState copyWith({
    SearchState? searchState,
    RecentSearchesState? recentSearchesState,
    bool? hasError,
    String? errorMessage,
    OrquestadorSearchEffect? effect,
  }) {
    return OrquestadorSearchState(
      searchState: searchState ?? this.searchState,
      recentSearchesState: recentSearchesState ?? this.recentSearchesState,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      effect: effect,
    );
  }

  factory OrquestadorSearchState.initial() => const OrquestadorSearchState(
        searchState: SearchState(),
        recentSearchesState: RecentSearchesState(),
      );

  @override
  List<Object?> get props => [
        searchState,
        recentSearchesState,
        hasError,
        errorMessage,
        effect,
      ];
}
