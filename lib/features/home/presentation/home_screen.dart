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
import 'package:music_app/features/home/presentation/widgets/mood_genres_grid_widget.dart';

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
                  // Header con saludo
                  const SliverToBoxAdapter(child: HomeHeaderWidget()),

                  // Secciones de contenido (tendencias, etc.) - igual que en el shimmer
                  ...homeResponse.sections.map(
                    (section) => SliverToBoxAdapter(
                      child: HomeSectionWidget(
                        section: section,
                        onSongTap: _playSong,
                        onPlaylistTap: (item) {
                          // Navegar a la playlist si tiene ID
                          if (item.playlistId != null &&
                              item.playlistId!.isNotEmpty) {
                            context.router.push(
                              PlaylistRoute(id: item.playlistId!),
                            );
                          }
                        },
                      ),
                    ),
                  ),

                  // GridView de categorías (moods y genres combinados) - al final como en el shimmer
                  MoodGenresGridWidget(
                    moods: homeResponse.moods,
                    genres: homeResponse.genres,
                  ),

                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
