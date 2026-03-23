import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class LikedSongsScreen extends StatelessWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LibraryCubit(
        getIt<LibraryService>(),
        getIt<OfflineService>(),
        context.read<PlayerBlocBloc>(),
      )..loadLibrary(),
      child: const Scaffold(
        backgroundColor: Color(0xFF0D0D0D),
        body: _LikedSongsScreenView(),
      ),
    );
  }
}

class _LikedSongsScreenView extends StatefulWidget {
  const _LikedSongsScreenView();

  @override
  State<_LikedSongsScreenView> createState() => _LikedSongsScreenViewState();
}

class _LikedSongsScreenViewState extends State<_LikedSongsScreenView> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      // Cargar más canciones cuando llegue al 80% del scroll
      context.read<LibraryCubit>().loadMoreSongs();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<LibraryCubit, LibraryState>(
      builder: (context, state) {
        return CustomScrollView(
          controller: _scrollController,
          slivers: [
            _buildHeader(context, state, l10n),
            if (state.status == LibraryStatus.loading) ...[
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Row(
                    children: [
                      ShimmerContainer(width: 56, height: 56, borderRadius: 28),
                      SizedBox(width: 16),
                      ShimmerContainer(width: 48, height: 48, borderRadius: 24),
                    ],
                  ),
                ),
              ),
              SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) => const SongListItemShimmer(),
                  childCount: 10,
                ),
              ),
            ] else if (state.status == LibraryStatus.failure)
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

  Widget _buildHeader(
    BuildContext context,
    LibraryState state,
    AppLocalizations l10n,
  ) {
    final totalText = state.totalSongs > 0
        ? '${state.totalSongs} ${l10n.likedSongsCount}'
        : l10n.likedSongs;

    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
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
              colors: [AppColorsDark.primaryContainer, Color(0xFF0D0D0D)],
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
                      colors: [AppColorsDark.primary, AppColorsDark.secondary],
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
    if (state.favoriteSongs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

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

  Widget _buildSongsList(
    BuildContext context,
    LibraryState state,
    AppLocalizations l10n,
  ) {
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
          // Mostrar indicador de carga al final de la lista
          if (index == state.favoriteSongs.length) {
            if (state.isLoadingMoreSongs) {
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(
                    color: AppColorsDark.primary,
                    strokeWidth: 2,
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }

          final song = state.favoriteSongs[index];
          return SongListItemWithRemove(
            title: song.title,
            artist: song.artist,
            thumbnail: song.thumbnail,
            onTap: () => _playSong(context, song),
            onRemove: () => _removeSong(context, song),
          );
        },
        childCount:
            state.favoriteSongs.length +
            (state.isLoadingMoreSongs || state.hasMoreSongs ? 1 : 0),
      ),
    );
  }

  Widget _buildError(
    String? errorMessage,
    BuildContext context,
    AppLocalizations l10n,
  ) {
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
    final nowPlayingData = context.read<LibraryCubit>().playAllFavoriteSongs(
      songs,
    );
    if (nowPlayingData != null) {
      // Playlist - mantener la lista
      context.router.push(
        PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: false),
      );
    }
  }

  void _playSong(BuildContext context, FavoriteSong song) {
    // Usar el método del Cubit
    final nowPlayingData = context.read<LibraryCubit>().playSong(song);
    // Canción individual
    context.router.push(
      PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: true),
    );
  }

  void _removeSong(BuildContext context, FavoriteSong song) {
    context.read<LibraryCubit>().toggleFavoriteSong(
      song.videoId,
      song.songId,
      currentlyFavorite: true,
    );
  }
}
