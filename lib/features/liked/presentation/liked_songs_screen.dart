import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';

import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<LibraryCubit>()..loadLibrary(),
      child: const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: _LikedSongsScreenView(),
      ),
    );
  }
}

class _LikedSongsScreenView extends StatelessWidget {
  const _LikedSongsScreenView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        return CustomScrollView(
          slivers: [
            _buildHeader(context, state, l10n),
            if (state.status == LibraryStatus.loading)
              const SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppColorsDark.primary),
                ),
              )
            else if (state.status == LibraryStatus.failure)
              SliverFillRemaining(
                child: _buildError(state.errorMessage, context, l10n),
              )
            else ...[
              _buildPlayButton(context, state),
              _buildSongsList(context, state, l10n),
            ],
          ],
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, LibraryState state, AppLocalizations l10n) {
    final totalText = state.totalSongs > 0 
        ? '${state.totalSongs} ${l10n.likedSongsCount}' 
        : l10n.likedSongs;

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
                Container(
                  width: 180,
                  height: 180,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
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
                Text(
                  l10n.likedSongs,
                  style: const TextStyle(
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

  Widget _buildSongsList(BuildContext context, LibraryState state, AppLocalizations l10n) {
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
                l10n.noLikedSongsYet,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                l10n.songsYouLikeWillAppearHere,
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
          return SongListItemWithRemove(
            title: song.title,
            artist: song.artist,
            thumbnail: song.thumbnail,
            onTap: () => _playSong(context, song),
            onRemove: () => _removeSong(context, song),
          );
        },
        childCount: state.favoriteSongs.length,
      ),
    );
  }

  Widget _buildError(String? errorMessage, BuildContext context, AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            errorMessage ?? l10n.errorLoadingSongs,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<LibraryCubit>().loadLibrary(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsDark.primary,
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  void _playAll(BuildContext context, List<FavoriteSong> songs) {
    if (songs.isEmpty) return;

    // Usar el método del Cubit
    final nowPlayingData = context.read<LibraryCubit>().playAllFavoriteSongs(songs);
    if (nowPlayingData != null) {
      // Navegar al reproductor
      context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
    }
  }

  void _playSong(BuildContext context, FavoriteSong song) {
    // Usar el método del Cubit
    final nowPlayingData = context.read<LibraryCubit>().playSong(song);
    // Navegar al reproductor
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
