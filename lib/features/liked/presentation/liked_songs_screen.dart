import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/main.dart';

@RoutePage()
class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LibraryCubit>()..loadLibrary(),
      child: Scaffold(
        backgroundColor: const Color(0xFF0D0D0D),
        body: const _LikedSongsScreenView(),
      ),
    );
  }
}

class _LikedSongsScreenView extends StatelessWidget {
  const _LikedSongsScreenView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            _buildHeader(context, state),
            if (state.status == LibraryStatus.loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColorsDark.primary),
                ),
              )
            else if (state.status == LibraryStatus.failure)
              SliverFillRemaining(
                child: _buildError(state.errorMessage, context),
              )
            else ...[
              _buildPlayButton(context, state),
              _buildSongsList(context, state),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, LibraryState state) {
    final totalText = state.totalSongs > 0 ? '${state.totalSongs} liked songs' : 'Liked Songs';

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.router.maybePop(),
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
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColorsDark.primaryContainer,
                const Color(0xFF0D0D0D),
              ],
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppColorsDark.primary,
                        AppColorsDark.secondary,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.favorite,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Liked Songs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  totalText,
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

  Widget _buildPlayButton(BuildContext context, LibraryState state) {
    if (state.favoriteSongs.isEmpty) return const SliverToBoxAdapter(child: SizedBox.shrink());

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => _playAll(context, state.favoriteSongs),
              child: Container(
                width: 56,
                height: 56,
                decoration: const BoxDecoration(
                  color: AppColorsDark.primary,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.play_arrow,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
            const SizedBox(width: 16),
            IconButton(
              icon: const Icon(Icons.shuffle, color: Colors.white),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSongsList(BuildContext context, LibraryState state) {
    if (state.favoriteSongs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.favorite_border,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No liked songs yet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Songs you like will appear here',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
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
          final song = state.favoriteSongs[index];
          return _SongItem(
            index: index + 1,
            song: song,
            onTap: () => _playSong(context, song),
            onRemove: () => _removeSong(context, song),
          );
        },
        childCount: state.favoriteSongs.length,
      ),
    );
  }

  Widget _buildError(String? errorMessage, BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? 'Error loading songs',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<LibraryCubit>().loadLibrary(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsDark.primary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  NowPlayingData _mapToNowPlaying(FavoriteSong s) {
    return NowPlayingData.fromBasic(
      videoId: s.videoId,
      title: s.title,
      artistNames: s.artist.split(', '),
      albumName: '',
      duration: s.duration != null ? _formatDuration(s.duration!) : '0:00',
      durationSeconds: s.duration,
      thumbnailUrl: s.thumbnail,
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  void _playAll(BuildContext context, List<FavoriteSong> songs) {
    if (songs.isEmpty) return;

    final playlist = songs.map(_mapToNowPlaying).toList();

    getIt<PlayerBlocBloc>().add(LoadPlaylistEvent(
      playlist: playlist,
      startIndex: 0,
    ));
    context.router.push(PlayerRoute(nowPlayingData: playlist.first));
  }

  void _playSong(BuildContext context, FavoriteSong song) {
    final nowPlayingData = _mapToNowPlaying(song);
    getIt<PlayerBlocBloc>().add(LoadTrackEvent(nowPlayingData));
    context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
  }

  void _removeSong(BuildContext context, FavoriteSong song) {
    context.read<LibraryCubit>().toggleFavoriteSong(
      song.videoId,
      song.songId,
      currentlyFavorite: true,
    );
  }
}

class _SongItem extends StatelessWidget {
  final int index;
  final FavoriteSong song;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _SongItem({
    required this.index,
    required this.song,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 40,
            child: Text(
              '$index',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: Container(
              width: 48,
              height: 48,
              color: AppColorsDark.primaryContainer,
              child: song.thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: song.thumbnail!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) => Icon(
                        Icons.music_note,
                        color: AppColorsDark.primary,
                      ),
                    )
                  : Icon(Icons.music_note, color: AppColorsDark.primary),
            ),
          ),
        ],
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: IconButton(
        icon: Icon(Icons.favorite, color: AppColorsDark.primary, size: 20),
        onPressed: onRemove,
      ),
      onTap: onTap,
    );
  }
}
