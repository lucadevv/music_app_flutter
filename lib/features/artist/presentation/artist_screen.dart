import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/artist/domain/entities/artist.dart';
import 'package:music_app/features/artist/presentation/cubit/artist_cubit.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class ArtistScreen extends StatelessWidget {
  final String artistId;

  const ArtistScreen({@PathParam('id') required this.artistId, super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GetIt.I<ArtistCubit>()..loadArtist(artistId),
      child: _ArtistView(artistId: artistId),
    );
  }
}

class _ArtistView extends StatelessWidget {
  final String artistId;

  const _ArtistView({required this.artistId});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: BlocBuilder<ArtistCubit, ArtistState>(
        builder: (context, state) {
          if (state.status == ArtistStatus.loading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColorsDark.primary),
            );
          }

          if (state.status == ArtistStatus.failure) {
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
                    onPressed: () =>
                        context.read<ArtistCubit>().loadArtist(artistId),
                    child: Text(l10n.retry),
                  ),
                ],
              ),
            );
          }

          final artist = state.artist;
          if (artist == null) {
            return const Center(child: CircularProgressIndicator());
          }

          return RefreshIndicator(
            color: AppColorsDark.primary,
            onRefresh: () async {
              await context.read<ArtistCubit>().loadArtist(artistId);
            },
            child: CustomScrollView(
              slivers: [
                // App Bar con imagen de fondo
                _buildSliverAppBar(context, artist),

                // Content
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action buttons
                        _buildActionButtons(context, artist, state, l10n),
                        const SizedBox(height: 32),

                        // Top Songs
                        if (state.topSongs.isNotEmpty) ...[
                          Text(
                            l10n.popular,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ],
                    ),
                  ),
                ),

                // Songs list
                if (state.topSongs.isNotEmpty)
                  SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final song = state.topSongs[index];
                      return _ArtistSongItem(
                        song: song,
                        index: index + 1,
                        onTap: () => _playSong(context, song, state.topSongs),
                      );
                    }, childCount: state.topSongs.length),
                  ),

                // Albums
                if (state.albums.isNotEmpty) ...[
                  const SliverToBoxAdapter(
                    child: Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Text(
                        'Albums',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: SizedBox(
                      height: 180,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: state.albums.length,
                        itemBuilder: (context, index) {
                          final album = state.albums[index];
                          return _ArtistAlbumCard(
                            album: album,
                            onTap: () => context.router.push(
                              AlbumRoute(albumId: album.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildSliverAppBar(BuildContext context, Artist artist) {
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
          child: artist.thumbnail != null
              ? CachedNetworkImage(
                  imageUrl: artist.thumbnail!,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => _buildDefaultArtistImage(),
                )
              : _buildDefaultArtistImage(),
        ),
      ),
    );
  }

  Widget _buildDefaultArtistImage() {
    return Center(
      child: Container(
        width: 150,
        height: 150,
        decoration: const BoxDecoration(
          color: AppColorsDark.primary,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.person, size: 80, color: Colors.white),
      ),
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    Artist artist,
    ArtistState state,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () {
              if (state.topSongs.isNotEmpty) {
                _playAllTopSongs(context, state.topSongs);
              }
            },
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
        IconButton(
          icon: Icon(
            state.isFollowing ? Icons.favorite : Icons.favorite_border,
            color: state.isFollowing ? AppColorsDark.primary : Colors.white,
          ),
          onPressed: () => context.read<ArtistCubit>().toggleFollow(),
        ),
        IconButton(
          icon: const Icon(Icons.share, color: Colors.white),
          onPressed: () {},
        ),
      ],
    );
  }

  void _playSong(
    BuildContext context,
    ArtistSong song,
    List<ArtistSong> allSongs,
  ) {
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

  void _playAllTopSongs(BuildContext context, List<ArtistSong> songs) {
    if (songs.isEmpty) return;

    final playlist = songs
        .map(
          (song) => NowPlayingData.fromBasic(
            videoId: song.videoId,
            title: song.title,
            artistNames: const [],
            albumName: '',
            duration: song.formattedDuration,
            durationSeconds: song.durationSeconds,
            thumbnailUrl: song.thumbnail,
          ),
        )
        .toList();

    context.read<PlayerBlocBloc>().add(
      LoadPlaylistEvent(playlist: playlist, startIndex: 0),
    );

    context.router.push(PlayerRoute(nowPlayingData: playlist.first));
  }
}

class _ArtistSongItem extends StatelessWidget {
  final ArtistSong song;
  final int index;
  final VoidCallback onTap;

  const _ArtistSongItem({
    required this.song,
    required this.index,
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

class _ArtistAlbumCard extends StatelessWidget {
  final ArtistAlbum album;
  final VoidCallback onTap;

  const _ArtistAlbumCard({required this.album, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 140,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 130,
                width: 140,
                color: AppColorsDark.primaryContainer,
                child: album.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: album.thumbnail!,
                        fit: BoxFit.cover,
                        errorWidget: (_, _, _) => const Icon(
                          Icons.album,
                          size: 48,
                          color: AppColorsDark.primary,
                        ),
                      )
                    : const Icon(
                        Icons.album,
                        size: 48,
                        color: AppColorsDark.primary,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              album.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '${album.year} • ${album.songCount} songs',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
