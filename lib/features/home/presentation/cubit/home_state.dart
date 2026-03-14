part of 'home_cubit.dart';

/// Estados del home
enum HomeStatus { initial, loading, success, failure }

/// Estado del cubit del home
class HomeState {
  final HomeStatus status;
  final String? errorMessage;
  final HomeResponse? homeResponse;

  final String _filterQuery;

  const HomeState({
    this.status = HomeStatus.initial,
    this.errorMessage,
    this.homeResponse,
    String filterQuery = '',
  }) : _filterQuery = filterQuery;

  /// Retorna las secciones de home filtradas por la query actual (Lógica de Dominio)
  List<HomeSection> get filteredSections {
    if (homeResponse == null) return [];
    if (_filterQuery.isEmpty) return homeResponse!.sections;

    return homeResponse!.sections.map((section) {
      final filteredItems = section.contents
          .where((item) => item.matchesQuery(_filterQuery))
          .toList();
      return section.copyWith(contents: filteredItems);
    }).where((section) => section.contents.isNotEmpty).toList();
  }

  HomeState copyWith({
    HomeStatus? status,
    String? errorMessage,
    HomeResponse? homeResponse,
    String? filterQuery,
    bool clearError = false,
  }) {
    return HomeState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      homeResponse: homeResponse ?? this.homeResponse,
      filterQuery: filterQuery ?? _filterQuery,
    );
  }
}
