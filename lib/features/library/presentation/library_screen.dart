import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/features/library/presentation/widgets/library_widgets.dart';
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
                    SliverFillRemaining(
                      child: LibraryEmptyState(
                        l10n: l10n,
                        onExplore: () => context.router.push(const HomeRoute()),
                      ),
                    ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  SliverAppBar _buildHeader(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      leading: BlocBuilder<ProfileCubit, ProfileState>(
        builder: (context, profileState) {
          return IconButton(
            icon: ProfileAvatar(
              avatarUrl: profileState.avatarUrl,
              initials: profileState.initials,
            ),
            onPressed: () => context.router.push(const MyProfileRoute()),
          );
        },
      ),
      title: Text(
        l10n.yourLibrary,
        style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
      ),
      actions: [
        PopupMenuButton<String>(
          icon: Icon(Icons.add, color: Colors.white.withValues(alpha: 0.8)),
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
                  Text(l10n.createPlaylist, style: const TextStyle(color: Colors.white)),
                ],
              ),
            ),
          ],
        ),
      ],
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

  SliverToBoxAdapter _buildQuickAccess(
    BuildContext context,
    LibraryState state,
    AppLocalizations l10n,
  ) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            QuickAccessChip(
              icon: Icons.favorite,
              label: l10n.likedSongs,
              count: state.totalSongs,
              onTap: () => context.router.push(const LikedSongsRoute()),
            ),
            QuickAccessChip(
              icon: Icons.history,
              label: l10n.recentlyPlayed,
              count: 0,
              onTap: () => context.router.push(const RecentlyPlayedRoute()),
            ),
            QuickAccessChip(
              icon: Icons.playlist_play,
              label: l10n.myPlaylists,
              count: state.totalPlaylists,
              onTap: () => context.router.push(const UserPlaylistsRoute()),
            ),
            QuickAccessChip(
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

  SliverToBoxAdapter _buildPlaylistsSection(
    BuildContext context,
    LibraryState state,
    AppLocalizations l10n,
  ) {
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
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (state.totalPlaylists > 5)
                  TextButton(
                    onPressed: () => context.router.push(const UserPlaylistsRoute()),
                    child: Text(l10n.seeAll, style: const TextStyle(color: AppColorsDark.primary, fontSize: 14)),
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
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: PlaylistCard(
                    playlist: playlist,
                    onTap: () {
                      if (playlist.isUserCreated) {
                        context.router.push(UserPlaylistDetailRoute(playlistId: playlist.id));
                      } else if (playlist.externalPlaylistId != null) {
                        context.router.push(PlaylistRoute(id: playlist.externalPlaylistId!));
                      }
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  SliverToBoxAdapter _buildSongsSection(
    BuildContext context,
    LibraryState state,
    AppLocalizations l10n,
  ) {
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
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (state.totalSongs > 5)
                  TextButton(
                    onPressed: () => context.router.push(const LikedSongsRoute()),
                    child: Text(l10n.seeAll, style: const TextStyle(color: AppColorsDark.primary, fontSize: 14)),
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
              return SongListItemWidget(
                song: song,
                onTap: () {
                  final nowPlayingData = context.read<LibraryCubit>().playSong(song);
                  context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
                },
                onOptionsTap: () => _showSongOptions(context, song, l10n),
              );
            },
          ),
        ],
      ),
    );
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
        title: Text(l10n.createPlaylist, style: const TextStyle(color: Colors.white)),
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
            child: Text(l10n.createPlaylist, style: const TextStyle(color: AppColorsDark.primary)),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      await context.read<LibraryCubit>().createPlaylist(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.createPlaylist}: $result'),
            backgroundColor: AppColorsDark.primary,
          ),
        );
      }
    }
  }
}
