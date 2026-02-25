part of 'search_cubit.dart';

enum SearchStatus {
  initial,
  loading,
  success,
  failure,
}

class SearchState extends Equatable {
  final SearchStatus status;
  final String? errorMessage;
  final SearchResponse? responseEntity;
  final String query;

  const SearchState({
    this.status = SearchStatus.initial,
    this.errorMessage,
    this.responseEntity,
    this.query = '',
  });

  SearchState copyWith({
    SearchStatus? status,
    String? errorMessage,
    SearchResponse? responseEntity,
    String? query,
  }) {
    return SearchState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      responseEntity: responseEntity ?? this.responseEntity,
      query: query ?? this.query,
    );
  }

  factory SearchState.initial() => const SearchState(
        status: SearchStatus.initial,
        errorMessage: null,
        responseEntity: null,
        query: '',
      );

  @override
  List<Object?> get props => [status, errorMessage, responseEntity, query];
}
