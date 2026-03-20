import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/home/domain/entities/home_content_item.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart'
    show HomeCubit, HomeStatus;
import 'package:music_app/features/home/presentation/cubit/orquestador_home_cubit.dart';
import 'package:music_app/features/home/presentation/widgets/atoms/home_error_widget.dart';
import 'package:music_app/features/home/presentation/widgets/molecules/home_header_widget.dart';
import 'package:music_app/features/home/presentation/widgets/organisms/categories_row_widget.dart';
import 'package:music_app/features/home/presentation/widgets/organisms/home_listeners.dart';
import 'package:music_app/features/home/presentation/widgets/organisms/home_loading_widget.dart';
import 'package:music_app/features/home/presentation/widgets/organisms/home_section_widget.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    context.read<HomeCubit>().loadHome();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileCubit = context.read<ProfileCubit>();
      if (profileCubit.state.profile == null && !profileCubit.state.isLoading) {
        profileCubit.loadProfile();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    context.read<OrquestadorHomeCubit>().filterHome(value);
  }

  Future<void> _onRefresh() async {
    await context.read<HomeCubit>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return HomeListeners(
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OrquestadorHomeCubit, OrquestadorHomeState>(
            builder: (context, orquestadorState) {
              final state = orquestadorState.homeState;
              final filterQueryTextEmpty = _searchController.text.isEmpty;

              // Loading inicial muestra shimmer completo
              if (state.status == HomeStatus.loading ||
                  state.status == HomeStatus.initial) {
                return const HomeLoadingWidget();
              }

              // Error con opción de reintentar
              if (state.status == HomeStatus.failure) {
                return HomeErrorWidget(
                  errorMessage: state.errorMessage ?? 'Unknown error',
                );
              }

              final homeResponse = state.homeResponse;
              if (homeResponse == null) {
                return _buildEmptyState('No content available');
              }

              final filteredSections = state.filteredSections;

              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _onRefresh,
                color: Colors.white,
                backgroundColor: Colors.black54,
                child: CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverToBoxAdapter(
                      child: HomeHeaderWidget(
                        searchController: _searchController,
                        onSearchChanged: _onSearchChanged,
                      ),
                    ),

                    if (filterQueryTextEmpty)
                      SliverToBoxAdapter(
                        child: CategoriesRowWidget(
                          moods: homeResponse.moods,
                          genres: homeResponse.genres,
                        ),
                      ),

                    // Empty state cuando no hay resultados de búsqueda
                    if (!filterQueryTextEmpty && filteredSections.isEmpty)
                      SliverFillRemaining(
                        child: _buildEmptyState(
                          'No results for "${_searchController.text}"',
                        ),
                      ),

                    ...filteredSections.map(
                      (section) => SliverToBoxAdapter(
                        child: HomeSectionWidget(
                          section: section,
                          onSongTap: _playSong,
                          onPlaylistTap: (item) {
                            if (item.playlistId != null &&
                                item.playlistId!.isNotEmpty) {
                              context.router.push(
                                PlaylistRoute(id: item.playlistId!),
                              );
                            }
                          },
                          onAlbumTap: (item) {
                            if (item.browseId != null &&
                                item.browseId!.isNotEmpty) {
                              context.router.push(
                                AlbumRoute(albumId: item.browseId!),
                              );
                            }
                          },
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _onRefresh,
            icon: const Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white24,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _playSong(HomeContentItem item) {
    final nowPlayingData = context
        .read<OrquestadorHomeCubit>()
        .playContentItemAsSingle(item);
    if (nowPlayingData != null) {
      context.router.push(
        PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: true),
      );
    }
  }
}
