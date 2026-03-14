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

  @override
  void initState() {
    super.initState();
    // Cargar datos del home al iniciar (no resetear para mantener el estado)
    context.read<HomeCubit>().loadHome();
    
    // Asegurar que el perfil esté cargado para mostrar avatar en el header
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

  @override
  Widget build(BuildContext context) {
    return HomeListeners(
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OrquestadorHomeCubit, OrquestadorHomeState>(
            builder: (context, orquestadorState) {
              final state = orquestadorState.homeState;
              final filterQueryTextEmpty = _searchController.text.isEmpty;

              // Mostrar shimmer cuando está cargando o en estado inicial
              if (state.status == HomeStatus.loading ||
                  state.status == HomeStatus.initial) {
                return const HomeLoadingWidget();
              }

              if (state.status == HomeStatus.failure) {
                return HomeErrorWidget(errorMessage: state.errorMessage);
              }

              final homeResponse = state.homeResponse;
              if (homeResponse == null) {
                return const SizedBox.shrink();
              }

              // Obtenemos las secciones ya filtradas por el dominio (HomeState)
              final filteredSections = state.filteredSections;

              return CustomScrollView(
                slivers: [
                  // Header with greeting & search bar
                  SliverToBoxAdapter(
                    child: HomeHeaderWidget(
                      searchController: _searchController,
                      onSearchChanged: _onSearchChanged,
                    ),
                  ),

                  // Categories (Moods & Genres) - solo mostrar si no hay búsqueda
                  if (filterQueryTextEmpty)
                    SliverToBoxAdapter(
                      child: CategoriesRowWidget(
                        moods: homeResponse.moods,
                        genres: homeResponse.genres,
                      ),
                    ),

                  // Mostrar mensaje si no hay resultados
                  if (!filterQueryTextEmpty && filteredSections.isEmpty)
                    SliverFillRemaining(
                      child: Center(
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
                              'No results for "${_searchController.text}"',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.7),
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  // Content Sections (Filtered or All)
                  ...filteredSections.map(
                    (section) => SliverToBoxAdapter(
                      child: HomeSectionWidget(
                        section: section,
                        onSongTap: _playSong,
                        onPlaylistTap: (item) {
                          if (item.playlistId != null && item.playlistId!.isNotEmpty) {
                            context.router.push(PlaylistRoute(id: item.playlistId!));
                          }
                        },
                        onAlbumTap: (item) {
                          if (item.browseId != null && item.browseId!.isNotEmpty) {
                            context.router.push(AlbumRoute(albumId: item.browseId!));
                          }
                        },
                      ),
                    ),
                  ),
                   
                  const SliverToBoxAdapter(child: SizedBox(height: 120)), // Space for bottom nav
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Reproduce una canción usando el OrquestadorHomeCubit
  void _playSong(HomeContentItem item) {
    final nowPlayingData = context
        .read<OrquestadorHomeCubit>()
        .playContentItemAsSingle(item);
    if (nowPlayingData != null) {
      context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
    }
  }
}
