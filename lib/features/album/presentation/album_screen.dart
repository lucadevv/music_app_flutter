import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/song_list_item.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/presentation/cubit/album_cubit.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class AlbumScreen extends StatelessWidget {
  final String albumId;

  const AlbumScreen({
    super.key,
    @PathParam('id') required this.albumId,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<AlbumCubit>()..loadAlbum(albumId),
      child: _AlbumView(albumId: albumId),
    );
  }
}

class _AlbumView extends StatelessWidget {
  final String albumId;

  const _AlbumView({required this.albumId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: BlocBuilder<AlbumCubit, AlbumState>(
        builder: (context, state) {
          if (state.status == AlbumStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColorsDark.primary),
            );
          }

          if (state.status == AlbumStatus.failure) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    state.errorMessage ?? l10n.errorLoadingPlaylist,
                    style: const TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.read<AlbumCubit>().loadAlbum(albumId),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final album = state.album;
          if (album == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            color: AppColorsDark.primary,
            onRefresh: () async {
              context.read<AlbumCubit>().loadAlbum(albumId);
            },
            child: CustomScrollView(
              slivers: [
                // App Bar
                _buildSliverAppBar(context, album),

                // Action buttons
                SliverToBoxAdapter(
                  child: _buildActionButtons(context, album, state, l10n),
                ),

                // Songs list
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final song = state.songs[index];
                      return _AlbumSongItem(
                        song: song,
                        onTap: () => _playSong(context, song, state.songs),
                      );
                    },
                    childCount: state.songs.length,
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Album album) {
    return SliverAppBar(
      expandedHeight: 300,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.router.pop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColorsDark.primaryContainer,
                Color(0xFF0D0D0D),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Album artwork
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    width: 180,
                    height: 180,
                    color: AppColorsDark.primary,
                    child: album.thumbnail != null
                        ? CachedNetworkImage(
                            imageUrl: album.thumbnail!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) => const Icon(
                              Icons.album,
                              size: 80,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.album,
                            size: 80,
                            color: Colors.white,
                          ),
                  ),
                ),
                const SizedBox(height: 16),

                // Album title
                Text(
                  album.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),

                // Artist and info
                Text(
                  '${album.artistName ?? 'Unknown Artist'} • ${album.year}',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Album album,
    AlbumState state,
    AppLocalizations l10n,
  ) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          // Play button
          Expanded(
            child: FilledButton.icon(
              onPressed: () => _playAllSongs(context, state.songs),
              icon: const Icon(Icons.play_arrow),
              label: Text(l10n.play),
              style: FilledButton.styleFrom(
                backgroundColor: AppColorsDark.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Like button
          IconButton(
            icon: Icon(
              state.isLiked ? Icons.favorite : Icons.favorite_border,
              color: state.isLiked ? Colors.red : Colors.white,
            ),
            onPressed: () => context.read<AlbumCubit>().toggleLike(),
          ),

          // Download button
          IconButton(
            icon: const Icon(Icons.download, color: Colors.white),
            onPressed: () {},
          ),

          // Shuffle button
          IconButton(
            icon: const Icon(Icons.shuffle, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  void _playSong(BuildContext context, AlbumSong song, List<AlbumSong> allSongs) {
    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: [allSongs.first.title],
      albumName: '',
      duration: song.formattedDuration,
      durationSeconds: song.durationSeconds,
      thumbnailUrl: song.thumbnail,
    );

    context.read<PlayerBlocBloc>().add(LoadTrackEvent(nowPlayingData));
    context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
  }

  void _playAllSongs(BuildContext context, List<AlbumSong> songs) {
    if (songs.isEmpty) return;

    final playlist = songs.map((song) => NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: [],
      albumName: '',
      duration: song.formattedDuration,
      durationSeconds: song.durationSeconds,
      thumbnailUrl: song.thumbnail,
    )).toList();

    context.read<PlayerBlocBloc>().add(LoadPlaylistEvent(playlist: playlist, startIndex: 0));

    context.router.push(PlayerRoute(nowPlayingData: playlist.first));
  }
}

class _AlbumSongItem extends StatelessWidget {
  final AlbumSong song;
  final VoidCallback onTap;

  const _AlbumSongItem({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SongListItemWithTrailing(
        title: song.title,
        artist: '',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              song.formattedDuration,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withValues(alpha: 0.6),
              ),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
