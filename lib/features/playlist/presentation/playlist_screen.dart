import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/playlist/domain/use_cases/get_playlist_use_case.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_state.dart';
import 'package:music_app/features/playlist/presentation/widgets/playlist_actions_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/playlist_error_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/playlist_header_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/playlist_listeners.dart';
import 'package:music_app/features/playlist/presentation/widgets/playlist_loading_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/playlist_track_item_widget.dart';
import 'package:music_app/main.dart';

@RoutePage()
class PlaylistScreen extends StatefulWidget implements AutoRouteWrapper {
  final String id;

  const PlaylistScreen({required this.id, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<PlaylistCubit>(
      create: (context) {
        return PlaylistCubit(
          getPlaylistUseCase: getIt<GetPlaylistUseCase>(),
          playerBloc: getIt<PlayerBlocBloc>(),
        );
      },
      child: this,
    );
  }

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.id.isNotEmpty) {
        context.read<PlaylistCubit>().loadPlaylist(widget.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final playerBloc = context.read<PlayerBlocBloc>();

    return PlaylistListeners(
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
          bloc: playerBloc,
          builder: (context, playerState) {
            // Ya no necesitamos el overlay de loading porque el botón tiene indicador
            return BlocBuilder<PlaylistCubit, PlaylistState>(
              builder: (context, playlistState) {
                // Mostrar loading
                if (playlistState.status == PlaylistStatus.loading ||
                    playlistState.status == PlaylistStatus.initial) {
                  return const PlaylistLoadingWidget();
                }

                // Mostrar error
                if (playlistState.status == PlaylistStatus.failure) {
                  return PlaylistErrorWidget(
                    errorMessage:
                        playlistState.errorMessage ?? 'Error desconocido',
                    playlistId: widget.id,
                  );
                }

                // Mostrar contenido
                final playlist = playlistState.response;
                if (playlist == null) {
                  return const PlaylistLoadingWidget();
                }

                // Obtener la mejor thumbnail del estado
                // final bestThumbnail obtenido de playlistState (no se usa aún)

                  return Stack(
                    children: [
                      // Backdrop difuminado (se conservará si se reintroduce la UI con la thumbnail)
                      // PlaylistBackdropWidget(thumbnail: bestThumbnail),

                      // Contenido con CustomScrollView
                      CustomScrollView(
                        slivers: [
                          // App Bar con imagen mejorado
                          SliverAppBar(
                            expandedHeight: 400,
                            pinned: true,
                            floating: false,
                            snap: false,
                            backgroundColor: Colors.transparent,
                            elevation: 0,
                            leading: Container(
                              margin: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.3),
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: () => context.router.pop(),
                              ),
                            ),
                            actions: [
                              Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.search,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                  icon: const Icon(
                                    Icons.more_vert,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                  onPressed: () {},
                                ),
                              ),
                            ],
                            flexibleSpace: FlexibleSpaceBar(
                              titlePadding: const EdgeInsets.only(
                                left: 16,
                                bottom: 16,
                                right: 16,
                              ),

                              background: PlaylistHeaderWidget(
                                playlist: playlist,
                              ),
                            ),
                          ),

                          // Action buttons
                          SliverToBoxAdapter(
                            child: PlaylistActionsWidget(playlist: playlist),
                          ),

                          // Lista de tracks
                          SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final track = playlist.tracks[index];
                              return PlaylistTrackItemWidget(
                                track: track,
                                allTracks: playlist.tracks,
                              );
                            }, childCount: playlist.tracks.length),
                          ),

                          const SliverToBoxAdapter(
                            child: SizedBox(height: 100),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              
            );
          },
        ),
      ),
    );
  }
}
