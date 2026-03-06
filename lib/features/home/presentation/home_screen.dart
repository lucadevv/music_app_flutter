import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/home/domain/entities/home_content_item.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart'
    show HomeCubit, HomeStatus;
import 'package:music_app/features/home/presentation/cubit/orquestador_home_cubit.dart';
import 'package:music_app/features/home/presentation/widgets/home_error_widget.dart';
import 'package:music_app/features/home/presentation/widgets/home_header_widget.dart';
import 'package:music_app/features/home/presentation/widgets/home_listeners.dart';
import 'package:music_app/features/home/presentation/widgets/home_loading_widget.dart';
import 'package:music_app/features/home/presentation/widgets/home_section_widget.dart';
import 'package:music_app/features/home/presentation/widgets/categories_row_widget.dart';

@RoutePage()
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar datos del home al iniciar (no resetear para mantener el estado)
    context.read<HomeCubit>().loadHome();
  }

  @override
  Widget build(BuildContext context) {
    return HomeListeners(
      child: Scaffold(
        body: SafeArea(
          child: BlocBuilder<OrquestadorHomeCubit, OrquestadorHomeState>(
            builder: (context, orquestadorState) {
              final state = orquestadorState.homeState;

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

              return CustomScrollView(
                slivers: [
                  // Header with greeting & search bar
                  const SliverToBoxAdapter(child: HomeHeaderWidget()),

                  // Categories (Moods & Genres)
                  SliverToBoxAdapter(
                    child: CategoriesRowWidget(
                      moods: homeResponse.moods,
                      genres: homeResponse.genres,
                    ),
                  ),

                  // Content Sections (Trending, Recently Listened, etc)
                  ...homeResponse.sections.map(
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
