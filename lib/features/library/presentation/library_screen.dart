import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/bottom_sheet_visibility.dart';
import 'package:music_app/core/widgets/song_list_item.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/downloads/presentation/widgets/download_option_tile.dart';
import 'package:music_app/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:music_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/profile/profile_cubit.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LibraryCubit>()..loadLibrary()),
        BlocProvider(create: (_) => getIt<ProfileCubit>()..loadProfile()),
      ],
      child: const _LibraryView(),
    );
  }
}

class _LibraryView extends StatelessWidget {
  const _LibraryView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: BlocBuilder<LibraryCubit, LibraryState>(
        builder: (context, state) {
          return RefreshIndicator(
            color: AppColorsDark.primary,
            onRefresh: () => context.read<LibraryCubit>().loadLibrary(),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: <Widget>[
                _buildHeader(context, l10n),
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
                  _buildQuickAccess(context, state, l10n),
                  if (state.favoritePlaylists.isNotEmpty)
                    _buildPlaylistsSection(context, state, l10n),
                  if (state.favoriteSongs.isNotEmpty)
                    _buildSongsSection(context, state, l10n),
                  if (state.isEmpty && state.status == LibraryStatus.success)
                    _buildEmptyState(context, l10n),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return IconButton(
            icon: _buildProfileAvatar(profileState),
            onPressed: () => context.router.push(const MyProfileRoute()),
          );
        },
      ),
      title: Text(
        l10n.yourLibrary,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
      actions: [
        // Botón de búsqueda eliminado - ya existe en otro tab
        PopupMenuButton<String>(
          icon: Icon(
            Icons.add,
            color: Colors.white.withValues(alpha: 0.8),
          ),
          color: AppColorsDark.surfaceContainerHigh,
          onSelected: (value) {
            if (value == 'create_playlist') {
              _showCreatePlaylistDialog(context);
            }
          },
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'create_playlist',
              child: Row(
                children: [
                  Icon(Icons.playlist_add, color: Colors.white.withValues(alpha: 0.8)),
                  const SizedBox(width: 12),
                  Text(
                    l10n.createPlaylist,
                    style: const TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildProfileAvatar(ProfileState profileState) {
    if (profileState.avatarUrl != null && profileState.avatarUrl!.isNotEmpty) {
      return Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(shape: BoxShape.circle),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profileState.avatarUrl!,
            fit: BoxFit.cover,
            placeholder: (_, __) => _buildInitialsAvatar(profileState, 32),
            errorWidget: (_, __, ___) => _buildInitialsAvatar(profileState, 32),
          ),
        ),
      );
    }
    return _buildInitialsAvatar(profileState, 32);
  }

  Widget _buildInitialsAvatar(ProfileState profileState, double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColorsDark.primary,
            AppColorsDark.primary.withValues(alpha: 0.7),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          profileState.initials,
          style: TextStyle(
            color: Colors.white,
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
          ),
        ),
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
            errorMessage ?? l10n.errorLoadingLibrary,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.read<LibraryCubit>().loadLibrary(),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAccess(BuildContext context, LibraryState state, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _QuickAccessChip(
              icon: Icons.favorite,
              label: l10n.likedSongs,
              count: state.totalSongs,
              onTap: () => context.router.push(const LikedSongsRoute()),
            ),
            _QuickAccessChip(
              icon: Icons.history,
              label: l10n.recentlyPlayed,
              count: 0,
              onTap: () => context.router.push(const RecentlyPlayedRoute()),
            ),
            _QuickAccessChip(
              icon: Icons.playlist_play,
              label: l10n.myPlaylists,
              count: state.totalPlaylists, // Ahora incluye todas las playlists
              onTap: () => context.router.push(const UserPlaylistsRoute()),
            ),
            _QuickAccessChip(
              icon: Icons.library_music,
              label: l10n.genres,
              count: state.totalGenres,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaylistsSection(BuildContext context, LibraryState state, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.playlists,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.totalPlaylists > 5)
                  TextButton(
                    onPressed: () => context.router.push(const UserPlaylistsRoute()),
                    child: Text(
                      l10n.seeAll,
                      style: const TextStyle(color: AppColorsDark.primary, fontSize: 14),
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
              itemCount: state.allPlaylists.length > 10 ? 10 : state.allPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = state.allPlaylists[index];
                return _PlaylistCard(
                  playlist: playlist,
                  onTap: () {
                    if (playlist.isUserCreated) {
                      // Playlist creada por el usuario - ir a UserPlaylistDetailRoute
                      context.router.push(UserPlaylistDetailRoute(playlistId: playlist.id));
                    } else if (playlist.externalPlaylistId != null) {
                      // Playlist de YouTube favorita - ir a PlaylistRoute
                      context.router.push(PlaylistRoute(id: playlist.externalPlaylistId!));
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSongsSection(BuildContext context, LibraryState state, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.likedSongs,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (state.totalSongs > 5)
                  TextButton(
                    onPressed: () => context.router.push(const LikedSongsRoute()),
                    child: Text(
                      l10n.seeAll,
                      style: const TextStyle(color: AppColorsDark.primary, fontSize: 14),
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
                onOptionsTap: () => _showSongOptions(context, song, l10n),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, AppLocalizations l10n) {
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
              l10n.yourLibraryIsEmpty,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.songsAndPlaylistsWillAppearHere,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.router.push(const HomeRoute()),
              icon: const Icon(Icons.explore),
              label: Text(l10n.exploreMusic),
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

  void _showSongOptions(BuildContext context, FavoriteSong song, AppLocalizations l10n) {
    SongOptionsBottomSheet.show(
      context: context,
      song: SongOptionsData(
        videoId: song.videoId,
        title: song.title,
        artist: song.artist,
        thumbnail: song.thumbnail,
        durationSeconds: song.duration,
        isFavorite: true,
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(
          l10n.createPlaylist,
          style: const TextStyle(color: Colors.white),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.playlistName,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppColorsDark.primary),
            ),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, nameController.text),
            child: Text(
              l10n.createPlaylist,
              style: const TextStyle(color: AppColorsDark.primary),
            ),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      try {
        final libraryService = getIt<LibraryService>();
        await libraryService.createUserPlaylist(name: result);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${l10n.createPlaylist}: $result'),
              backgroundColor: AppColorsDark.primary,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
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
  final PlaylistItem playlist;
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
                height: 130,
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
            if (playlist.songCount > 0)
              Text(
                '${playlist.songCount} songs',
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
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

