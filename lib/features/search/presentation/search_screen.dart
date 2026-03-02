import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/search/presentation/cubit/orquestador_search_cubit.dart';
import 'package:music_app/features/search/presentation/cubit/recent_searches_cubit.dart';
import 'package:music_app/features/search/presentation/cubit/search_cubit.dart'
    show SearchCubit, SearchStatus;
import 'package:music_app/features/search/presentation/widgets/categories_grid_widget.dart';

import 'package:music_app/features/search/presentation/widgets/search_bar_widget.dart';
import 'package:music_app/features/search/presentation/widgets/search_listeners.dart';
import 'package:music_app/features/search/presentation/widgets/search_results_widget.dart';
import 'package:music_app/features/search/presentation/widgets/trending_artists_widget.dart'
    show RecentSearchesWidget;

@RoutePage()
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Reiniciar estado de búsqueda al entrar
    context.read<OrquestadorSearchCubit>().resetSearchState();
    // Cargar búsquedas recientes al iniciar
    context.read<RecentSearchesCubit>().getRecentSearches();
  }

  @override
  void dispose() {
    // Cancelar el debounce al salir
    context.read<SearchCubit>().cancelDebounce();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    // Usar el método con debounce del Cubit
    context.read<SearchCubit>().searchWithDebounce(value);
  }

  @override
  Widget build(BuildContext context) {
    return SearchListeners(
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: SafeArea(
          child: BlocBuilder<OrquestadorSearchCubit, OrquestadorSearchState>(
            builder: (context, orquestadorState) {
              final searchState = orquestadorState.searchState;
              final hasQuery = searchState.query.isNotEmpty;
              final isLoading = searchState.status == SearchStatus.loading;
              final hasResults = searchState.status == SearchStatus.success &&
                  searchState.responseEntity != null;

              return CustomScrollView(
                slivers: [
                  // Search Bar
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: SearchBarWidget(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                      ),
                    ),
                  ),

                  // Mostrar loading si está buscando
                  if (isLoading)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        ),
                      ),
                    ),

                  // Mostrar resultados si hay búsqueda
                  if (hasQuery && hasResults)
                    SliverToBoxAdapter(
                      child: SearchResultsWidget(
                        results: searchState.responseEntity!.results,
                      ),
                    ),

                  // Mostrar lista y grid cuando no hay búsqueda
                  if (!hasQuery) ...[
                    // Búsquedas recientes
                    const SliverToBoxAdapter(
                      child: RecentSearchesWidget(),
                    ),

                    // Categories grid
                    const SliverToBoxAdapter(
                      child: CategoriesGridWidget(),
                    ),
                  ],

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
