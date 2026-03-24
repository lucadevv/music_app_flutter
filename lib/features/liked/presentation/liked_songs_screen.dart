import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/features/liked/presentation/widgets/widgets.dart';
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
            if (state.status == LibraryStatus.loading)
              const SliverFillRemaining(child: LikedSongsLoading())
            else if (state.status == LibraryStatus.failure)
              SliverFillRemaining(
                child: ErrorState(
                  message: state.errorMessage ?? l10n.errorLoadingSongs,
                  retryText: l10n.retry,
                  onRetry: () => context.read<LibraryCubit>().loadLibrary(),
                ),
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

    return LikedSongsHeader(
      title: l10n.likedSongs,
      subtitle: totalText,
      onBackTap: () => context.router.maybePop(),
      onSearchTap: () {},
      onMoreTap: () {},
    );
  }

  Widget _buildPlayButton(BuildContext context, LibraryState state) {
    if (state.favoriteSongs.isEmpty) {
      return const SliverToBoxAdapter(child: SizedBox.shrink());
    }

    return SliverToBoxAdapter(
      child: PlayControls(
        onPlayTap: () => _playAll(context, state.favoriteSongs),
        onShuffleTap: () {},
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
        child: EmptyLikedSongs(
          title: l10n.noLikedSongsYet,
          subtitle: l10n.songsYouLikeWillAppearHere,
        ),
      );
    }

    return LikedSongsList(
      songs: state.favoriteSongs,
      isLoadingMore: state.isLoadingMoreSongs,
      hasMore: state.hasMoreSongs,
      onSongTap: (song) => _playSong(context, song),
      onRemove: (song) => _removeSong(context, song),
    );
  }

  void _playAll(BuildContext context, List<FavoriteSong> songs) {
    if (songs.isEmpty) return;

    final nowPlayingData = context.read<LibraryCubit>().playAllFavoriteSongs(
      songs,
    );
    if (nowPlayingData != null) {
      context.router.push(
        PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: false),
      );
    }
  }

  void _playSong(BuildContext context, FavoriteSong song) {
    final nowPlayingData = context.read<LibraryCubit>().playSong(song);
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
