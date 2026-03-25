// ignore_for_file: deprecated_member_use_from_same_package
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/domain/repositories/album_repository.dart';
import 'package:music_app/features/album/domain/use_cases/get_album_songs_use_case.dart';
import 'package:music_app/features/album/domain/use_cases/get_album_use_case.dart';
import 'package:music_app/features/album/domain/use_cases/is_liked_album_use_case.dart';
import 'package:music_app/features/album/domain/use_cases/like_album_use_case.dart';
import 'package:music_app/features/album/domain/use_cases/unlike_album_use_case.dart';
import 'package:music_app/features/album/presentation/cubit/album_cubit.dart';
import 'package:music_app/features/album/presentation/widgets/molecules/molecules.dart';
import 'package:music_app/features/album/presentation/widgets/organisms/organisms.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';

@RoutePage()
class AlbumScreen extends StatelessWidget implements AutoRouteWrapper {
  final String albumId;

  const AlbumScreen({@PathParam('id') required this.albumId, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    final albumRepository = GetIt.I<AlbumRepository>();
    return BlocProvider(
      create: (_) => AlbumCubit(
        getAlbumUseCase: GetAlbumUseCase(albumRepository),
        getAlbumSongsUseCase: GetAlbumSongsUseCase(albumRepository),
        likeAlbumUseCase: LikeAlbumUseCase(albumRepository),
        unlikeAlbumUseCase: UnlikeAlbumUseCase(albumRepository),
        isLikedAlbumUseCase: IsLikedAlbumUseCase(albumRepository),
        playerBloc: context.read<PlayerBlocBloc>(),
      )..loadAlbum(albumId),
      child: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return _AlbumView(albumId: albumId);
  }
}

class _AlbumView extends StatelessWidget {
  final String albumId;

  const _AlbumView({required this.albumId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: BlocBuilder<AlbumCubit, AlbumState>(
        builder: (context, state) {
          if (state.status == AlbumStatus.loading) {
            return const AlbumLoadingView();
          }

          if (state.status == AlbumStatus.failure) {
            return AlbumErrorView(
              errorMessage: state.errorMessage,
              onRetry: () => context.read<AlbumCubit>().loadAlbum(albumId),
            );
          }

          final album = state.album;
          if (album == null) {
            return Center(
              child: Text(
                'Álbum no encontrado',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.7)),
              ),
            );
          }

          return RefreshIndicator(
            color: AppColorsDark.primary,
            onRefresh: () async {
              await context.read<AlbumCubit>().loadAlbum(albumId);
            },
            child: _AlbumMainContent(
              album: album,
              state: state,
              albumId: albumId,
            ),
          );
        },
      ),
    );
  }
}

class _AlbumMainContent extends StatelessWidget {
  final Album album;
  final AlbumState state;
  final String albumId;

  const _AlbumMainContent({
    required this.album,
    required this.state,
    required this.albumId,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // App Bar
        AlbumAppBar(album: album, onBackPressed: () => context.router.pop()),

        // Action buttons
        SliverToBoxAdapter(
          child: AlbumActionButtons(
            isLiked: state.isLiked,
            onPlayPressed: () => _playAllSongs(context, state.songs),
            onLikePressed: () => context.read<AlbumCubit>().toggleLike(),
          ),
        ),

        // Songs list
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final song = state.songs[index];
            return AlbumSongItem(
              song: song,
              onTap: () => _playSong(context, song, state.songs),
            );
          }, childCount: state.songs.length),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }

  void _playSong(
    BuildContext context,
    AlbumSong song,
    List<AlbumSong> allSongs,
  ) {
    final cubit = context.read<AlbumCubit>();
    final success = cubit.playSong(song, allSongs);

    if (success) {
      final nowPlayingData = cubit.mapAlbumSongToNowPlaying(song);
      context.router.push(
        PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: true),
      );
    }
  }

  void _playAllSongs(BuildContext context, List<AlbumSong> songs) {
    if (songs.isEmpty) return;

    final nowPlayingData = context.read<AlbumCubit>().playAllAlbumSongs(songs);

    if (nowPlayingData != null) {
      context.router.push(
        PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: false),
      );
    }
  }
}
