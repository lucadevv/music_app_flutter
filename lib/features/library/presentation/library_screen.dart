import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:music_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/main.dart';

@RoutePage()
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<LibraryCubit>()..loadLibrary(),
      child: const _LibraryView(),
    );
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColorsDark.primary,
            onRefresh: () => context.read<LibraryCubit>().loadLibrary(),
            child: CustomScrollView(
              slivers: [
                _buildHeader(context),
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
                  _buildQuickAccess(context, state),
                  if (state.favoritePlaylists.isNotEmpty)
                    _buildPlaylistsSection(context, state),
                  if (state.favoriteSongs.isNotEmpty)
                    _buildSongsSection(context, state),
                  if (state.isEmpty && state.status == LibraryStatus.success)
                    _buildEmptyState(context),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColorsDark.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            color: AppColorsDark.primary,
            size: 24,
          ),
        ),
        onPressed: () => context.router.push(const ProfileRoute()),
      ),
      title: const Text(
        'Your Library',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.search,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          onPressed: () {},
        ),
        IconButton(
          icon: Icon(
            Icons.add,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          onPressed: () {},
        ),
      ],
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
            errorMessage ?? 'Error loading library',
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<LibraryCubit>().loadLibrary(),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context, LibraryState state) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickAccessChip(
              icon: Icons.favorite,
              label: 'Liked Songs',
              count: state.totalSongs,
              onTap: () => context.router.push(const LikedSongsRoute()),
            ),
            _QuickAccessChip(
              icon: Icons.playlist_play,
              label: 'Playlists',
              count: state.totalPlaylists,
              onTap: () {},
            ),
            _QuickAccessChip(
              icon: Icons.library_music,
              label: 'Genres',
              count: state.totalGenres,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsSection(BuildContext context, LibraryState state) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Playlists',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.totalPlaylists > 5)
                  TextButton(
                    onPressed: () {},
                    child: const Text(
                      'See all',
                      style: TextStyle(color: AppColorsDark.primary, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 180,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.favoritePlaylists.length > 10 ? 10 : state.favoritePlaylists.length,
              itemBuilder: (context, index) {
                final playlist = state.favoritePlaylists[index];
                return _PlaylistCard(
                  playlist: playlist,
                  onTap: () => context.router.push(
                    PlaylistRoute(id: playlist.externalPlaylistId),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsSection(BuildContext context, LibraryState state) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Liked Songs',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.totalSongs > 5)
                  TextButton(
                    onPressed: () => context.router.push(const LikedSongsRoute()),
                    child: const Text(
                      'See all',
                      style: TextStyle(color: AppColorsDark.primary, fontSize: 14),
                    ),
                  ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: state.favoriteSongs.length > 10 ? 10 : state.favoriteSongs.length,
            itemBuilder: (context, index) {
              final song = state.favoriteSongs[index];
              return _SongListItem(
                song: song,
                onTap: () => _playSong(context, song, state.favoriteSongs),
                onOptionsTap: () => _showSongOptions(context, song),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.library_music,
              size: 64,
              color: Colors.white.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'Your library is empty',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Songs and playlists you like will appear here',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.router.push(const HomeRoute()),
              icon: const Icon(Icons.explore),
              label: const Text('Explore Music'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColorsDark.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _playSong(BuildContext context, FavoriteSong song, List<FavoriteSong> allSongs) {
    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: song.videoId,
      title: song.title,
      artistNames: song.artist.split(', '),
      albumName: '',
      duration: song.duration != null ? _formatDuration(song.duration!) : '0:00',
      durationSeconds: song.duration,
      thumbnailUrl: song.thumbnail,
    );

    getIt<PlayerBlocBloc>().add(LoadTrackEvent(nowPlayingData));
    context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
  }

  void _showSongOptions(BuildContext context, FavoriteSong song) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsDark.surfaceContainerHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _SongOptionsSheet(song: song),
    );
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }
}

class _QuickAccessChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final VoidCallback onTap;

  const _QuickAccessChip({
    required this.icon,
    required this.label,
    required this.count,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: AppColorsDark.primary, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 14),
            ),
            if (count > 0) ...[
              const SizedBox(width: 4),
              Text(
                '($count)',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _PlaylistCard extends StatelessWidget {
  final FavoritePlaylist playlist;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.playlist,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.symmetric(horizontal: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                height: 140,
                width: 140,
                color: AppColorsDark.primaryContainer,
                child: playlist.thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: playlist.thumbnail!,
                        fit: BoxFit.cover,
                        placeholder: (_, __) => Icon(
                          Icons.playlist_play,
                          size: 48,
                          color: AppColorsDark.primary,
                        ),
                        errorWidget: (_, __, ___) => Icon(
                          Icons.playlist_play,
                          size: 48,
                          color: AppColorsDark.primary,
                        ),
                      )
                    : Icon(
                        Icons.playlist_play,
                        size: 48,
                        color: AppColorsDark.primary,
                      ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              playlist.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

class _SongListItem extends StatelessWidget {
  final FavoriteSong song;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const _SongListItem({
    required this.song,
    required this.onTap,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: ClipRRect(
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
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FavoriteButton(
            videoId: song.videoId,
            songId: song.songId,
            size: 22,
            metadata: SongMetadata(
              title: song.title,
              artist: song.artist,
              thumbnail: song.thumbnail,
              duration: song.duration,
            ),
            onToggle: () {
              // Recargar la librería después de un cambio
              context.read<LibraryCubit>().loadLibrary();
            },
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            onPressed: onOptionsTap,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _SongOptionsSheet extends StatelessWidget {
  final FavoriteSong song;

  const _SongOptionsSheet({required this.song});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: ClipRRect(
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
            title: Text(
              song.title,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              song.artist,
              style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
            ),
          ),
          const Divider(color: Colors.white24),
          _OptionTile(
            icon: Icons.heart_broken,
            label: 'Remove from Liked Songs',
            onTap: () {
              Navigator.pop(context);
              // Usar videoId para eliminar (el backend ahora lo soporta)
              context.read<LibraryCubit>().toggleFavoriteSong(
                    song.videoId,
                    song.videoId, // El backend ahora acepta videoId
                    currentlyFavorite: true,
                  );
            },
          ),
          _OptionTile(
            icon: Icons.playlist_add,
            label: 'Add to Playlist',
            onTap: () => Navigator.pop(context),
          ),
          _OptionTile(
            icon: Icons.share,
            label: 'Share',
            onTap: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _OptionTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: Colors.white70),
      title: Text(label, style: const TextStyle(color: Colors.white)),
      onTap: onTap,
    );
  }
}
