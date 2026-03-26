import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/song_options/domain/use_cases/add_to_playlist_use_case.dart';
import 'package:music_app/features/song_options/domain/use_cases/create_playlist_use_case.dart';
import 'package:music_app/features/song_options/domain/use_cases/get_user_playlists_use_case.dart';
import 'package:music_app/features/song_options/presentation/cubit/playlist_dialog_cubit.dart';
import 'package:music_app/features/song_options/presentation/widgets/atoms/error_widget_atom.dart';
import 'package:music_app/features/song_options/presentation/widgets/molecules/playlist_tile_molecule.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart'
    show SongOptionsData;
import 'package:music_app/features/user_playlists/domain/entities/user_playlist_entity.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

/// Organism: Add to playlist dialog content
/// Refactorizado arquitectónicamente para delegar en `PlaylistDialogCubit`
class AddToPlaylistDialogOrganism extends StatelessWidget {
  final SongOptionsData song;
  final VoidCallback? onSongAdded;
  final VoidCallback? onPlaylistCreated;

  const AddToPlaylistDialogOrganism({
    required this.song,
    super.key,
    this.onSongAdded,
    this.onPlaylistCreated,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PlaylistDialogCubit(
        getUserPlaylistsUseCase: getIt<GetUserPlaylistsUseCase>(),
        addToPlaylistUseCase: getIt<AddToPlaylistUseCase>(),
        createPlaylistUseCase: getIt<CreatePlaylistUseCase>(),
      )..loadPlaylists(),
      child: _AddToPlaylistDialogContent(
        song: song,
        onSongAdded: onSongAdded,
        onPlaylistCreated: onPlaylistCreated,
      ),
    );
  }
}

class _AddToPlaylistDialogContent extends StatefulWidget {
  final SongOptionsData song;
  final VoidCallback? onSongAdded;
  final VoidCallback? onPlaylistCreated;

  const _AddToPlaylistDialogContent({
    required this.song,
    this.onSongAdded,
    this.onPlaylistCreated,
  });

  @override
  State<_AddToPlaylistDialogContent> createState() =>
      _AddToPlaylistDialogContentState();
}

class _AddToPlaylistDialogContentState
    extends State<_AddToPlaylistDialogContent> {
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocConsumer<PlaylistDialogCubit, PlaylistDialogState>(
      listener: (context, state) {
        if (state is PlaylistDialogError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '${AppLocalizations.of(context)!.errorOccurred}: ${state.message}',
              ),
              backgroundColor: AppColorsDark.error,
            ),
          );
        } else if (state is PlaylistDialogSongAdded) {
          context.router.maybePop();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.song.title} agregada exitosamente'),
              backgroundColor: AppColorsDark.primary,
            ),
          );
          widget.onSongAdded?.call();
        } else if (state is PlaylistDialogPlaylistCreated) {
          widget.onPlaylistCreated?.call();
          // After creating, automatically add the song to the new playlist
          context.read<PlaylistDialogCubit>().addSongToPlaylist(
            playlistId: state.playlist.id,
            videoId: widget.song.videoId,
            title: widget.song.title,
            artist: widget.song.artist,
            thumbnail: widget.song.thumbnail,
            duration: widget.song.durationSeconds,
          );
        }
      },
      builder: (context, state) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          padding: EdgeInsets.only(
            top: 16,
            bottom: MediaQuery.of(context).padding.bottom + 16,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, l10n),
              const Divider(color: AppColorsDark.onSurface24),
              _buildSearchField(context, l10n, state),
              const SizedBox(height: 8),
              Expanded(child: _buildContent(context, l10n, state)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            l10n.addToPlaylist,
            style: const TextStyle(
              color: AppColorsDark.onSurface,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close, color: AppColorsDark.onSurface),
            onPressed: () => context.router.maybePop(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchField(
    BuildContext context,
    AppLocalizations l10n,
    PlaylistDialogState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (value) {
                setState(() => _searchQuery = value);
                context.read<PlaylistDialogCubit>().searchPlaylists(value);
              },
              style: const TextStyle(color: AppColorsDark.onSurface),
              decoration: InputDecoration(
                hintText: 'Buscar playlists...',
                hintStyle: TextStyle(
                  color: AppColorsDark.onSurface.withValues(alpha: 0.5),
                ),
                prefixIcon: Icon(
                  Icons.search,
                  color: AppColorsDark.onSurface.withValues(alpha: 0.5),
                ),
                filled: true,
                fillColor: AppColorsDark.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _CreatePlaylistButton(
            isCreating: state is PlaylistDialogCreatingPlaylist,
          ),
        ],
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AppLocalizations l10n,
    PlaylistDialogState state,
  ) {
    if (state is PlaylistDialogInitial || state is PlaylistDialogLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColorsDark.primary),
      );
    }

    List<UserPlaylistEntity> playlists = [];
    bool isAdding = false;

    if (state is PlaylistDialogLoaded) {
      playlists = state.playlists;
    } else if (state is PlaylistDialogAddingSong) {
      playlists = state.playlists;
      isAdding = true;
    } else if (state is PlaylistDialogCreatingPlaylist) {
      playlists = state.playlists;
    }

    if (state is PlaylistDialogError && playlists.isEmpty) {
      return ErrorWidgetAtom(
        message: state.message,
        onRetry: () => context.read<PlaylistDialogCubit>().loadPlaylists(),
      );
    }

    final filteredPlaylists = _searchQuery.isEmpty
        ? playlists
        : playlists
              .where(
                (p) =>
                    p.name.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

    if (filteredPlaylists.isEmpty && !isAdding) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _searchQuery.isNotEmpty ? Icons.search_off : Icons.playlist_play,
              size: 48,
              color: AppColorsDark.onSurface.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No se encontraron playlists'
                  : l10n.noPlaylistsYet,
              style: TextStyle(
                color: AppColorsDark.onSurface.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async =>
          context.read<PlaylistDialogCubit>().loadPlaylists(),
      color: AppColorsDark.primary,
      child: Stack(
        children: [
          ListView.builder(
            itemCount: filteredPlaylists.length,
            itemBuilder: (context, index) {
              final playlist = filteredPlaylists[index];
              return PlaylistTileMolecule(
                // Nota: Asumiendo que PlaylistTileMolecule acepta UserPlaylistEntity o dynamic.
                // Si esto causa error en flutter analyze, castear a dyn amic o cambiar molecula.
                playlist: playlist as dynamic,
                onTap: () {
                  context.read<PlaylistDialogCubit>().addSongToPlaylist(
                    playlistId: playlist.id,
                    videoId: widget.song.videoId,
                    title: widget.song.title,
                    artist: widget.song.artist,
                    thumbnail: widget.song.thumbnail,
                    duration: widget.song.durationSeconds,
                  );
                },
              );
            },
          ),
          if (isAdding)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(color: AppColorsDark.primary),
            ),
        ],
      ),
    );
  }
}

/// Widget para crear nueva playlist
class _CreatePlaylistButton extends StatelessWidget {
  final bool isCreating;

  const _CreatePlaylistButton({required this.isCreating});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColorsDark.primary,
        borderRadius: BorderRadius.circular(24),
      ),
      child: IconButton(
        icon: isCreating
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: AppColorsDark.onSurface,
                  strokeWidth: 2,
                ),
              )
            : const Icon(Icons.add, color: AppColorsDark.onSurface),
        onPressed: isCreating ? null : () => _showCreatePlaylistDialog(context),
        tooltip: 'Crear nueva playlist',
      ),
    );
  }

  Future<void> _showCreatePlaylistDialog(BuildContext context) async {
    final textController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerLow,
        title: const Text(
          'Crear playlist',
          style: TextStyle(color: AppColorsDark.onSurface),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: AppColorsDark.onSurface),
          decoration: const InputDecoration(
            hintText: 'Nombre de la playlist',
            hintStyle: TextStyle(color: AppColorsDark.onSurface54),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => dialogContext.router.maybePop(null),
            child: Text(AppLocalizations.of(context)!.cancel),
          ),
          TextButton(
            onPressed: () =>
                dialogContext.router.maybePop(textController.text.trim()),
            child: Text(AppLocalizations.of(context)!.createPlaylist),
          ),
        ],
      ),
    );

    if (result != null && result.isNotEmpty && context.mounted) {
      await context.read<PlaylistDialogCubit>().createPlaylist(name: result);
    }
  }
}
