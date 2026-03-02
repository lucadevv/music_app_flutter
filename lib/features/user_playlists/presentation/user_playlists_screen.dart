import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/user_playlists/presentation/cubit/user_playlists_cubit.dart';
import 'package:music_app/features/user_playlists/presentation/cubit/user_playlists_state.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class UserPlaylistsScreen extends StatelessWidget {
  const UserPlaylistsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserPlaylistsCubit(
        libraryService: context.read<LibraryService>(),
      )..loadAllPlaylists(),
      child: const _UserPlaylistsView(),
    );
  }
}

class _UserPlaylistsView extends StatelessWidget {
  const _UserPlaylistsView();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          l10n.myPlaylists,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.router.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            onPressed: () => _createPlaylist(context, l10n),
          ),
        ],
      ),
      body: BlocBuilder<UserPlaylistsCubit, UserPlaylistsState>(
        builder: (context, state) {
          return _buildBody(context, state, l10n);
        },
      ),
    );
  }

  Widget _buildBody(BuildContext context, UserPlaylistsState state, AppLocalizations l10n) {
    switch (state.status) {
      case UserPlaylistsStatus.initial:
      case UserPlaylistsStatus.loading:
        return const Center(
          child: CircularProgressIndicator(color: AppColorsDark.primary),
        );
      case UserPlaylistsStatus.failure:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
          Text(
            state.errorMessage ?? l10n.errorUnknown,
            style: const TextStyle(color: Colors.white),
          ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  context.read<UserPlaylistsCubit>().loadAllPlaylists();
                },
                child: Text(l10n.retry),
              ),
            ],
          ),
        );
      case UserPlaylistsStatus.success:
        if (state.playlists.isEmpty) {
          return _buildEmptyState(l10n);
        }
        return _buildPlaylistGrid(context, state.playlists);
    }
  }

  Widget _buildEmptyState(AppLocalizations l10n) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.playlist_play,
            size: 64,
            color: Colors.white24,
          ),
          SizedBox(height: 16),
          Text(
            'No playlists',
            style: TextStyle(color: Colors.white54),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistGrid(BuildContext context, List<PlaylistItem> playlists) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: playlists.length,
      itemBuilder: (context, index) {
        final playlist = playlists[index];
        return _PlaylistCard(
          name: playlist.name,
          thumbnail: playlist.thumbnail,
          songCount: playlist.songCount,
          onTap: () {
            if (playlist.type == PlaylistType.user) {
              context.router.push(UserPlaylistDetailRoute(playlistId: playlist.id));
            } else {
              context.router.push(PlaylistRoute(id: playlist.externalId ?? playlist.id));
            }
          },
        );
      },
    );
  }

  Future<void> _createPlaylist(BuildContext context, AppLocalizations l10n) async {
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
      await context.read<UserPlaylistsCubit>().createPlaylist(result);
    }
  }
}

class _PlaylistCard extends StatelessWidget {
  final String name;
  final String? thumbnail;
  final int songCount;
  final VoidCallback onTap;

  const _PlaylistCard({
    required this.name,
    required this.songCount,
    required this.onTap,
    this.thumbnail,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: thumbnail != null
                  ? CachedNetworkImage(
                      imageUrl: thumbnail!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                    )
                  : Container(
                      color: AppColorsDark.surfaceContainerHighest,
                      child: const Center(
                        child: Icon(
                          Icons.playlist_play,
                          size: 48,
                          color: Colors.white24,
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            '$songCount songs',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
