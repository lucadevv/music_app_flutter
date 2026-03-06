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
import 'dart:ui';
import 'package:music_app/main.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

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
          playerBloc: context.read<PlayerBlocBloc>(),
        );
      },
      child: this,
    );
  }

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.id.isNotEmpty) {
        context.read<PlaylistCubit>().loadPlaylist(widget.id);
      }
    });

    // Listener para infinite scroll
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Carg más cuando llegue al 80% del scroll
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<PlaylistCubit>().loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final playerBloc = context.read<PlayerBlocBloc>();

    return PlaylistListeners(
      child: Scaffold(
        backgroundColor: AppColorsDark.surface,
        body: BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
          bloc: playerBloc,
          builder: (context, playerState) {
            return BlocBuilder<PlaylistCubit, PlaylistState>(
              builder: (context, playlistState) {
                // Mostrar loading inicial
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

                return Stack(
                  children: [
                    // Contenido con CustomScrollView
                    CustomScrollView(
                      controller: _scrollController,
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
                          flexibleSpace: ClipRRect(
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                              child: FlexibleSpaceBar(
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
                          ),
                        ),

                        // Action buttons
                        SliverToBoxAdapter(
                          child: PlaylistActionsWidget(playlist: playlist),
                        ),

                        // Lista de tracks con infinite scroll
                        _buildTrackList(playlistState),

                        // Indicador de carga más
                        if (playlistState.status == PlaylistStatus.loadingMore)
                          const SliverToBoxAdapter(
                            child: Padding(
                              padding: EdgeInsets.all(16),
                              child: Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white54,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Mensaje de "cargar más" si hay más
                        if (playlistState.hasMore && 
                            playlistState.status != PlaylistStatus.loadingMore)
                          SliverToBoxAdapter(
                            child: _buildLoadMoreButton(playlistState),
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

  /// Construye la lista de tracks
  Widget _buildTrackList(PlaylistState playlistState) {
    final playlist = playlistState.response!;
    final tracks = playlist.tracks;

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final track = tracks[index];
          return PlaylistTrackItemWidget(
            track: track,
            allTracks: tracks,
          );
        },
        childCount: tracks.length,
      ),
    );
  }

  /// Botón para cargar más tracks
  Widget _buildLoadMoreButton(PlaylistState playlistState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: () {
          context.read<PlaylistCubit>().loadMore();
        },
        child: Text(
          'Cargar más canciones (${playlistState.allTracks.length}/${playlistState.response?.trackCount ?? '?'})',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
