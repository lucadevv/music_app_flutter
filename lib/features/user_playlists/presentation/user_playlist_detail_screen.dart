// import 'package:flutter/foundation.dart';
import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
// Removed hard dependency on routes in this detail screen for now; navigation uses context.router.
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/bottom_sheet_visibility.dart';
import 'package:music_app/core/utils/bottom_sheet_transition.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';

import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/search/domain/entities/search_request.dart';
import 'package:music_app/features/search/domain/repositories/search_repository.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';
import 'package:music_app/features/user_playlists/presentation/cubit/user_playlist_detail_cubit.dart';
import 'package:music_app/features/user_playlists/presentation/cubit/user_playlist_detail_state.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class UserPlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const UserPlaylistDetailScreen({
    @PathParam('id') required this.playlistId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserPlaylistDetailCubit(
        libraryService: GetIt.I<LibraryService>(),
        playerBloc: context.read<PlayerBlocBloc>(),
      )..loadPlaylist(playlistId),
      child: _UserPlaylistDetailView(playlistId: playlistId),
    );
  }
}

class _UserPlaylistDetailView extends StatelessWidget {
  final String playlistId;

  const _UserPlaylistDetailView({required this.playlistId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<UserPlaylistDetailCubit, UserPlaylistDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: _buildBody(context, state, l10n),
          floatingActionButton: state.status == UserPlaylistDetailStatus.success
              ? FloatingActionButton(
                  onPressed: () => _showAddSongsDialog(context, l10n),
                  backgroundColor: AppColorsDark.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Future<void> _showAddSongsDialog(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final searchRepository = GetIt.I<SearchRepository>();
    final cubit = context.read<UserPlaylistDetailCubit>();
    final searchController = TextEditingController();
    List<dynamic> searchResults = [];
    bool isLoading = false;
    String? error;
    Set<String> selectedVideoIds = {};

    await BottomSheetVisibility().showBottomSheet(
      context: context,
      builder: (bottomSheetContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) {
          return Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(dialogContext).size.height * 0.8,
            ),
            padding: EdgeInsets.only(
              top: 16,
              bottom: MediaQuery.of(dialogContext).padding.bottom + 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Agregar canciones',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          if (selectedVideoIds.isNotEmpty)
                            TextButton(
                              onPressed: () async {
                                bool allSuccess = true;
                                for (final song in searchResults) {
                                  final videoId = song.videoId ?? '';
                                  if (selectedVideoIds.contains(videoId)) {
                                    final success = await cubit
                                        .addSongToPlaylist(
                                          playlistId: playlistId,
                                          videoId: videoId,
                                          title: song.title ?? '',
                                          artist: _getArtistNames(song),
                                          thumbnail: song.thumbnailUrl,
                                          duration: song.durationSeconds,
                                        );
                                    if (!success) allSuccess = false;
                                  }
                                }
                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                  ScaffoldMessenger.of(
                                    dialogContext,
                                  ).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        allSuccess
                                            ? '${selectedVideoIds.length} canción(es) agregada(s)'
                                            : 'Algunas canciones no pudieron ser agregadas',
                                      ),
                                      backgroundColor: allSuccess
                                          ? AppColorsDark.primary
                                          : Colors.orange,
                                    ),
                                  );
                                }
                              },
                              child: Text(
                                'Agregar (${selectedVideoIds.length})',
                                style: const TextStyle(
                                  color: AppColorsDark.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.white),
                            onPressed: () => Navigator.pop(dialogContext),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Divider(color: Colors.white24),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextField(
                    controller: searchController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Buscar canciones...',
                      hintStyle: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: Colors.white.withValues(alpha: 0.5),
                      ),
                      filled: true,
                      fillColor: AppColorsDark.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onSubmitted: (query) async {
                      await _performSearch(
                        query,
                        searchRepository,
                        setDialogState,
                        (results) => searchResults = results,
                        (loading) => isLoading = loading,
                        (err) => error = err,
                      );
                    },
                  ),
                ),
                const SizedBox(height: 8),
                if (isLoading)
                  const Expanded(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: AppColorsDark.primary,
                      ),
                    ),
                  )
                else if (error != null)
                  Expanded(
                    child: Center(
                      child: Text(
                        error!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  )
                else if (searchResults.isEmpty)
                  Expanded(
                    child: Center(
                      child: Text(
                        searchController.text.isEmpty
                            ? 'Busca una canción para agregar'
                            : 'No se encontraron resultados',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: searchResults.length,
                      itemBuilder: (context, index) {
                        final song = searchResults[index];
                        final videoId = song.videoId ?? '';
                        final isSelected = selectedVideoIds.contains(videoId);
                        return ListTile(
                          leading: ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Container(
                              width: 48,
                              height: 48,
                              color: AppColorsDark.primaryContainer,
                              child: song.thumbnailUrl != null
                                  ? CachedNetworkImage(
                                      imageUrl: song.thumbnailUrl!,
                                      fit: BoxFit.cover,
                                      errorWidget: (_, __, ___) =>
                                          const Icon(Icons.music_note),
                                    )
                                  : const Icon(
                                      Icons.music_note,
                                      color: AppColorsDark.primary,
                                    ),
                            ),
                          ),
                          title: Text(
                            song.title ?? '',
                            style: const TextStyle(color: Colors.white),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            _getArtistNames(song),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.6),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              isSelected
                                  ? Icons.check_circle
                                  : Icons.add_circle_outline,
                              color: isSelected
                                  ? AppColorsDark.primary
                                  : Colors.white70,
                            ),
                            onPressed: () {
                              setDialogState(() {
                                if (isSelected) {
                                  selectedVideoIds.remove(videoId);
                                } else {
                                  selectedVideoIds.add(videoId);
                                }
                              });
                            },
                          ),
                          onTap: () {
                            setDialogState(() {
                              if (isSelected) {
                                selectedVideoIds.remove(videoId);
                              } else {
                                selectedVideoIds.add(videoId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _getArtistNames(dynamic song) {
    if (song.artistNames != null) {
      if (song.artistNames is List) {
        return (song.artistNames as List).join(', ');
      }
      return song.artistNames.toString();
    }
    return '';
  }

  Future<void> _performSearch(
    String query,
    SearchRepository searchRepository,
    void Function(void Function()) setState,
    void Function(List) setResults,
    void Function(bool) setLoading,
    void Function(String?) setError,
  ) async {
    if (query.trim().isEmpty) {
      setResults([]);
      return;
    }
    setLoading(true);
    setError(null);
    try {
      final result = await searchRepository.search(
        SearchRequest(query: query, filter: 'songs'),
      );
      result.fold(
        (failure) {
          setError(failure.toString());
          setResults([]);
        },
        (response) {
          setResults(response.results ?? []);
        },
      );
    } catch (e) {
      setError(e.toString());
      setResults([]);
    }
    setLoading(false);
  }

  Widget _buildBody(
    BuildContext context,
    UserPlaylistDetailState state,
    AppLocalizations l10n,
  ) {
    switch (state.status) {
      case UserPlaylistDetailStatus.initial:
      case UserPlaylistDetailStatus.loading:
        return const _UserPlaylistDetailLoadingView();
      case UserPlaylistDetailStatus.failure:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                state.errorMessage ?? 'Error desconocido',
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<UserPlaylistDetailCubit>().loadPlaylist(
                    playlistId,
                  );
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        );
      case UserPlaylistDetailStatus.success:
        if (state.playlist == null) {
          return const Center(
            child: Text(
              'Playlist not found',
              style: TextStyle(color: Colors.white),
            ),
          );
        }
        return _buildPlaylistContent(context, state, l10n);
    }
  }

  Widget _buildPlaylistContent(
    BuildContext context,
    UserPlaylistDetailState state,
    AppLocalizations l10n,
  ) {
    final playlist = state.playlist!;
    final cubit = context.read<UserPlaylistDetailCubit>();

    return CustomScrollView(
      slivers: [
        // App Bar
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: const Color(0xFF0D0D0D),
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              playlist.name,
              style: const TextStyle(color: Colors.white),
            ),
            background: playlist.thumbnail != null
                ? CachedNetworkImage(
                    imageUrl: playlist.thumbnail!,
                    fit: BoxFit.cover,
                    color: Colors.black54,
                    colorBlendMode: BlendMode.darken,
                  )
                : Container(
                    color: AppColorsDark.surfaceContainerHighest,
                    child: const Icon(
                      Icons.playlist_play,
                      size: 100,
                      color: Colors.white24,
                    ),
                  ),
          ),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (value) {
                switch (value) {
                  case 'edit':
                    _showEditDialog(context, playlist.name, l10n);
                    break;
                  case 'delete':
                    _confirmDelete(context, l10n);
                    break;
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      const Icon(Icons.edit, color: Colors.white),
                      const SizedBox(width: 8),
                      Text(l10n.edit),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      const Icon(Icons.delete, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        l10n.delete,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),

        // Botones de acción
        SliverToBoxAdapter(
          child:
              BlocSelector<
                PlayerBlocBloc,
                PlayerBlocState,
                ({String? sourceId, bool isPlaying, bool hasCurrentTrack})
              >(
                selector: (state) => (
                  sourceId: state.sourceId,
                  isPlaying: state.isPlaying,
                  hasCurrentTrack: state.hasCurrentTrack,
                ),
                builder: (context, playerData) {
                  final isCurrentPlaylist = playerData.sourceId == playlist.id;
                  final isPlaying = playerData.isPlaying;
                  final hasCurrentTrack = playerData.hasCurrentTrack;

                  // DEBUG: Verificar valores
                  debugPrint(
                    'DEBUG BlocSelector: sourceId=${playerData.sourceId}, playlist.id=${playlist.id}, isCurrentPlaylist=$isCurrentPlaylist, isPlaying=$isPlaying',
                  );

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            if (isCurrentPlaylist && hasCurrentTrack) {
                              // Si es la misma playlist, toggle play/pause
                              context.read<PlayerBlocBloc>().add(
                                const PlayPauseToggleEvent(),
                              );
                            } else {
                              // Si es otra playlist, cargar y reproducir
                              cubit.playAll();
                            }
                          },
                          icon: Icon(
                            isCurrentPlaylist && isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          label: Text(
                            isCurrentPlaylist && isPlaying
                                ? l10n.pause
                                : l10n.play,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColorsDark.primary,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
        ),

        // Lista de canciones
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final song = playlist.songs[index];
            return _PlaylistSongItem(
              videoId: song.videoId,
              title: song.title,
              artist: song.artist,
              duration: song.duration,
              thumbnail: song.thumbnail,
              onTap: () {
                cubit.playSong(index);
              },
            );
          }, childCount: playlist.songs.length),
        ),
      ],
    );
  }

  void _showEditDialog(
    BuildContext context,
    String currentName,
    AppLocalizations l10n,
  ) {
    final nameController = TextEditingController(text: currentName);
    final cubit = context.read<UserPlaylistDetailCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(l10n.edit, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.playlistName,
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              cubit.updatePlaylist(playlistId, nameController.text);
            },
            child: Text(
              l10n.save,
              style: const TextStyle(color: AppColorsDark.primary),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context, AppLocalizations l10n) {
    final cubit = context.read<UserPlaylistDetailCubit>();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
        content: const Text(
          // Fallback si la key localization no está disponible
          'Are you sure you want to delete this playlist?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await cubit.deletePlaylist(playlistId);
              if (context.mounted) {
                context.router.pop();
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

class _PlaylistSongItem extends StatelessWidget {
  final String videoId;
  final String title;
  final String artist;
  final int? duration;
  final String? thumbnail;
  final VoidCallback onTap;

  const _PlaylistSongItem({
    required this.videoId,
    required this.title,
    required this.artist,
    required this.onTap,
    this.duration,
    this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return SongListItem(
      title: title,
      artist: artist,
      thumbnail: thumbnail,
      onTap: onTap,
      trailing: IconButton(
        icon: Icon(Icons.more_vert, color: Colors.white.withValues(alpha: 0.6)),
        onPressed: () {
          SongOptionsBottomSheet.show(
            context: context,
            song: SongOptionsData(
              videoId: videoId,
              title: title,
              artist: artist,
              thumbnail: thumbnail,
              durationSeconds: duration,
              isFavorite: false,
            ),
          );
        },
      ),
    );
  }
}

class _UserPlaylistDetailLoadingView extends StatelessWidget {
  const _UserPlaylistDetailLoadingView();

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        const SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: Color(0xFF0D0D0D),
          flexibleSpace: FlexibleSpaceBar(
            background: ThumbnailShimmer(width: double.infinity, height: 300),
          ),
        ),
        const SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Row(children: [ButtonShimmer(width: 120, height: 48)]),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => const SongListItemShimmer(),
            childCount: 10,
          ),
        ),
      ],
    );
  }
}
