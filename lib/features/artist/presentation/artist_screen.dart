// ignore_for_file: deprecated_member_use_from_same_package
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/domain/entities/artist.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/artist/domain/repositories/artist_repository.dart';
import 'package:music_app/features/artist/domain/use_cases/follow_artist_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/get_artist_albums_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/get_artist_top_songs_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/get_artist_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/is_following_artist_use_case.dart';
import 'package:music_app/features/artist/domain/use_cases/unfollow_artist_use_case.dart';
import 'package:music_app/features/artist/presentation/cubit/artist_cubit.dart';
import 'package:music_app/features/artist/presentation/widgets/atoms/artist_error_widget.dart';
import 'package:music_app/features/artist/presentation/widgets/atoms/artist_not_found_widget.dart';
import 'package:music_app/features/artist/presentation/widgets/molecules/artist_action_buttons.dart';
import 'package:music_app/features/artist/presentation/widgets/molecules/artist_loading_molecule.dart';
import 'package:music_app/features/artist/presentation/widgets/organisms/artist_albums_organism.dart';
import 'package:music_app/features/artist/presentation/widgets/organisms/artist_header_organism.dart';
import 'package:music_app/features/artist/presentation/widgets/organisms/artist_top_songs_organism.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';

@RoutePage()
class ArtistScreen extends StatelessWidget implements AutoRouteWrapper {
  final String artistId;

  const ArtistScreen({@PathParam('id') required this.artistId, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    final artistRepository = GetIt.I<ArtistRepository>();
    return BlocProvider(
      create: (_) => ArtistCubit(
        getArtistUseCase: GetArtistUseCase(artistRepository),
        getArtistTopSongsUseCase: GetArtistTopSongsUseCase(artistRepository),
        getArtistAlbumsUseCase: GetArtistAlbumsUseCase(artistRepository),
        followArtistUseCase: FollowArtistUseCase(artistRepository),
        unfollowArtistUseCase: UnfollowArtistUseCase(artistRepository),
        isFollowingArtistUseCase: IsFollowingArtistUseCase(artistRepository),
        playerBloc: context.read<PlayerBlocBloc>(),
      )..loadArtist(artistId),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _ArtistView(artistId: artistId);
  }
}

class _ArtistView extends StatelessWidget {
  final String artistId;

  const _ArtistView({required this.artistId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: BlocBuilder<ArtistCubit, ArtistState>(
        builder: (context, state) {
          if (state.status == ArtistStatus.loading) {
            return const ArtistLoadingMolecule();
          }

          if (state.status == ArtistStatus.failure) {
            return ArtistErrorWidget(
              errorMessage: state.errorMessage,
              onRetry: () => context.read<ArtistCubit>().loadArtist(artistId),
            );
          }

          final artist = state.artist;
          if (artist == null) {
            return const ArtistNotFoundWidget();
          }

          return RefreshIndicator(
            color: AppColorsDark.primary,
            onRefresh: () async {
              await context.read<ArtistCubit>().loadArtist(artistId);
            },
            child: CustomScrollView(
              slivers: [
                ArtistHeaderOrganism(
                  artist: artist,
                  state: state,
                  onBackPressed: () => context.router.pop(),
                ),
                SliverToBoxAdapter(child: _buildPopularSection(context, state)),
                if (state.topSongs.isNotEmpty)
                  ArtistTopSongsOrganism(
                    songs: state.topSongs,
                    onSongTap: (song, allSongs) =>
                        _playSong(context, song, allSongs),
                  ),
                ArtistAlbumsOrganism(
                  albums: state.albums,
                  router: context.router,
                ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPopularSection(BuildContext context, ArtistState state) {
    if (state.topSongs.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ArtistActionButtons(
            artist: state.artist!,
            state: state,
            onPlayPressed: () => _playAllTopSongs(context, state.topSongs),
            onFollowPressed: () => context.read<ArtistCubit>().toggleFollow(),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _playSong(
    BuildContext context,
    ArtistSong song,
    List<ArtistSong> allSongs,
  ) {
    final cubit = context.read<ArtistCubit>();
    final success = cubit.playSong(song, allSongs);

    if (success) {
      final nowPlayingData = cubit.mapArtistSongToNowPlaying(song);
      context.router.push(
        PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: true),
      );
    }
  }

  void _playAllTopSongs(BuildContext context, List<ArtistSong> songs) {
    if (songs.isEmpty) return;

    final nowPlayingData = context.read<ArtistCubit>().playAllTopSongs(songs);

    if (nowPlayingData != null) {
      context.router.push(
        PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: false),
      );
    }
  }
}
