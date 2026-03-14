part of 'search_cubit.dart';

enum SearchStatus { initial, loading, loadingMore, success, failure }

class SearchState extends Equatable {
  final SearchStatus status;
  final String? errorMessage;
  final SearchResponse? responseEntity;
  final String query;
  final bool hasMore;
  final int currentPage;

  const SearchState({
    this.status = SearchStatus.initial,
    this.errorMessage,
    this.responseEntity,
    this.query = '',
    this.hasMore = true,
    this.currentPage = 0,
  });

  SearchState copyWith({
    SearchStatus? status,
    String? errorMessage,
    SearchResponse? responseEntity,
    String? query,
    bool? hasMore,
    int? currentPage,
  }) {
    return SearchState(
      status: status ?? this.status,
      errorMessage: errorMessage,
      responseEntity: responseEntity ?? this.responseEntity,
      query: query ?? this.query,
      hasMore: hasMore ?? this.hasMore,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  factory SearchState.initial() => const SearchState(
    status: SearchStatus.initial,
    errorMessage: null,
    responseEntity: null,
    query: '',
    hasMore: true,
    currentPage: 0,
  );

  @override
  List<Object?> get props => [status, errorMessage, responseEntity, query, hasMore, currentPage];
}
