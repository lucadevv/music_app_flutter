import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/mood_genre/domain/use_cases/get_mood_playlists_use_case.dart';
import 'package:music_app/main.dart';
import 'cubit/mood_genre_cubit.dart';
import 'widgets/mood_genre_error_widget.dart';
import 'widgets/mood_genre_listeners.dart';
import 'widgets/mood_genre_loading_widget.dart';
import 'widgets/mood_playlist_card_widget.dart';

@RoutePage()
class MoodGenreScreen extends StatefulWidget implements AutoRouteWrapper {
  final String params;

  const MoodGenreScreen({super.key, required this.params});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<MoodGenreCubit>(
      create: (context) {
        return MoodGenreCubit(
          getIt<GetMoodPlaylistsUseCase>(),
        );
      },
      child: this,
    );
  }

  @override
  State<MoodGenreScreen> createState() => _MoodGenreScreenState();
}

class _MoodGenreScreenState extends State<MoodGenreScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar playlists al iniciar
    context.read<MoodGenreCubit>().loadMoodPlaylists(widget.params);
  }

  @override
  Widget build(BuildContext context) {
    return MoodGenreListeners(
      child: Scaffold(
        body: BlocBuilder<MoodGenreCubit, MoodGenreState>(
          builder: (context, state) {
            // Mostrar loading cuando está cargando o en estado inicial
            if (state.status == MoodGenreStatus.loading ||
                state.status == MoodGenreStatus.initial) {
              return const MoodGenreLoadingWidget();
            }

            // Mostrar error si falló
            if (state.status == MoodGenreStatus.failure) {
              return MoodGenreErrorWidget(
                errorMessage: state.errorMessage,
                params: widget.params,
              );
            }

            // Mostrar contenido si fue exitoso
            final response = state.response;
            if (response == null) {
              return const SizedBox.shrink();
            }

            return CustomScrollView(
              slivers: [
                // Header con título del género
                SliverAppBar(
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  leading: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.router.pop(),
                  ),
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      response.genreName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    centerTitle: false,
                  ),
                ),

                // Lista de playlists
                if (response.playlists.isEmpty)
                  const SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text(
                          'No hay playlists disponibles',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  )
                else
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                      child: Text(
                        'Playlists de la comunidad',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),

                // Grid de playlists
                if (response.playlists.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.75,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final playlist = response.playlists[index];
                        return MoodPlaylistCardWidget(
                          playlist: playlist,
                          onTap: () {
                            // Debug: Verificar el browseId antes de navegar
                            print('MoodGenreScreen: Navigating to playlist with browseId: ${playlist.browseId}');
                            print('MoodGenreScreen: browseId isEmpty: ${playlist.browseId.isEmpty}');
                            
                            // Navegar a la playlist usando el browseId
                            if (playlist.browseId.isNotEmpty) {
                              context.router.push(
                                PlaylistRoute(id: playlist.browseId),
                              );
                            } else {
                              print('MoodGenreScreen: ERROR - browseId is empty!');
                            }
                          },
                        );
                      }, childCount: response.playlists.length),
                    ),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }
}
