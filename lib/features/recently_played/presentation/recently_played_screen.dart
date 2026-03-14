import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/domain/usecases/get_recently_played_usecase.dart';
import 'package:music_app/features/recently_played/presentation/cubit/recently_played_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class RecentlyPlayedScreen extends StatelessWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecentlyPlayedCubit(
        getRecentlyPlayedUseCase: getIt<GetRecentlyPlayedUseCase>(),
        playerBloc: context.read<PlayerBlocBloc>(),
      )..loadRecentlyPlayed(),
      child: const _RecentlyPlayedView(),
    );
  }
}

class _RecentlyPlayedView extends StatelessWidget {
  const _RecentlyPlayedView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: BlocBuilder<RecentlyPlayedCubit, RecentlyPlayedState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              _buildHeader(context, state, l10n),
              if (state.status == RecentlyPlayedStatus.loading)
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => const SongListItemShimmer(),
                    childCount: 10,
                  ),
                )
              else if (state.status == RecentlyPlayedStatus.failure)
                SliverFillRemaining(
                  child: _buildError(state.errorMessage, context, l10n),
                )
              else if (state.songs.isEmpty)
                SliverFillRemaining(child: _buildEmpty(l10n))
              else
                _buildSongsList(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    RecentlyPlayedState state,
    AppLocalizations l10n,
  ) {
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
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 140,
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
                      Icons.history,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.recentlyPlayed,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${state.songs.length} ${l10n.songs}',
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
      ),
    );
  }

  Widget _buildSongsList(BuildContext context, RecentlyPlayedState state) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        final song = state.songs[index];
        return _SongItem(song: song, onTap: () => _playSong(context, song));
      }, childCount: state.songs.length),
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
            onPressed: () =>
                context.read<RecentlyPlayedCubit>().loadRecentlyPlayed(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsDark.primary,
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRecentlyPlayed,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.songsYouListenToWillAppearHere,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _playSong(BuildContext context, RecentlyPlayedSong song) {
    final nowPlayingData = context.read<RecentlyPlayedCubit>().playSong(song);
    context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
  }
}

class _SongItem extends StatelessWidget {
  final RecentlyPlayedSong song;
  final VoidCallback onTap;

  const _SongItem({required this.song, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SongListItemWithTrailing(
      title: song.title,
      artist: song.artist,
      thumbnail: song.thumbnail,
      trailing: Icon(
        Icons.play_circle_outline,
        color: Colors.white.withValues(alpha: 0.6),
      ),
      onTap: onTap,
    );
  }
}
