// ignore_for_file: avoid_dynamic_calls
import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/playlist/domain/use_cases/get_playlist_use_case.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_state.dart';
import 'package:music_app/features/playlist/presentation/widgets/atoms/playlist_error_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/molecules/playlist_loading_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/playlist_actions_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/playlist_header_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/playlist_listeners.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/playlist_track_item_widget.dart';
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
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.id.isNotEmpty) {
        context.read<PlaylistCubit>().loadPlaylist(widget.id);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<PlaylistCubit>().loadMore();
    }
  }

  void _onSearchChanged(String value) {
    context.read<PlaylistCubit>().filterPlaylist(value);
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        context.read<PlaylistCubit>().filterPlaylist('');
      }
    });
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
                    CustomScrollView(
                      controller: _scrollController,
                      slivers: [
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
                                Icons.arrow_back_ios_new,
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
                                icon: Icon(
                                  _showSearch ? Icons.close : Icons.search,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                onPressed: _toggleSearch,
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
                                onPressed: () => _showPlaylistMenu(context, playlist),
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

                        // Barra de búsqueda
                        if (_showSearch)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                              child: TextField(
                                controller: _searchController,
                                onChanged: _onSearchChanged,
                                style: const TextStyle(color: Colors.white),
                                decoration: InputDecoration(
                                  hintText: 'Search songs...',
                                  hintStyle: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.white.withValues(alpha: 0.5),
                                  ),
                                  filled: true,
                                  fillColor: Colors.white.withValues(alpha: 0.1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(24),
                                    borderSide: BorderSide.none,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                ),
                              ),
                            ),
                          ),

                        // Action buttons
                        SliverToBoxAdapter(
                          child: PlaylistActionsWidget(playlist: playlist),
                        ),

                        // Lista de tracks
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

                        // Mensaje de cargar más
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

  Widget _buildTrackList(PlaylistState playlistState) {
    final tracks = playlistState.filteredResponseTracks;
    final filterQueryTextEmpty = _searchController.text.isEmpty;

    // Mostrar mensaje si no hay resultados
    if (!filterQueryTextEmpty && tracks.isEmpty) {
      return SliverFillRemaining(
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
      );
    }

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

  Widget _buildLoadMoreButton(PlaylistState playlistState) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextButton(
        onPressed: () {
          context.read<PlaylistCubit>().loadMore();
        },
        child: Text(
          'Cargar más canciones (${playlistState.allTracks.length}/${playlistState.response?.trackCount ?? "?"})',
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  void _showPlaylistMenu(BuildContext context, dynamic playlist) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsDark.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(top: 12, bottom: 20),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.share, color: Colors.white),
              title: const Text('Share', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
                _sharePlaylist(playlist);
              },
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add, color: Colors.white),
              title: const Text('Add to playlist', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.shuffle, color: Colors.white),
              title: const Text('Shuffle play', style: TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _sharePlaylist(dynamic playlist) {
    final shareText = 'Check out this playlist: ${playlist.title}';
    Clipboard.setData(ClipboardData(text: shareText));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Playlist link copied to clipboard'),
          backgroundColor: AppColorsDark.primary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      );
    }
  }
}
