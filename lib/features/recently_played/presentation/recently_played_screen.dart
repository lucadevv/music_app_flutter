import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/recently_played/domain/entities/recently_played_song.dart';
import 'package:music_app/features/recently_played/domain/usecases/get_recently_played_usecase.dart';
import 'package:music_app/features/recently_played/presentation/cubit/recently_played_cubit.dart';
import 'package:music_app/features/recently_played/presentation/widgets/widgets.dart';
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
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: BlocBuilder<RecentlyPlayedCubit, RecentlyPlayedState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              RecentlyPlayedHeaderOrganism(songCount: state.songs.length),
              _buildContent(context, state),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, RecentlyPlayedState state) {
    if (state.status == RecentlyPlayedStatus.loading) {
      return const RecentlyPlayedLoadingOrganism();
    } else if (state.status == RecentlyPlayedStatus.failure) {
      return SliverFillRemaining(
        child: RecentlyPlayedErrorOrganism(errorMessage: state.errorMessage),
      );
    } else if (state.songs.isEmpty) {
      return const SliverFillRemaining(child: RecentlyPlayedEmptyOrganism());
    } else {
      return RecentlyPlayedSongsOrganism(
        songs: state.songs,
        onPlaySong: (song) => _playSong(context, song),
      );
    }
  }

  NowPlayingData _playSong(BuildContext context, RecentlyPlayedSong song) {
    final nowPlayingData = context.read<RecentlyPlayedCubit>().playSong(song);
    return nowPlayingData;
  }
}
