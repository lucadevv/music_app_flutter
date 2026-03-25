import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/domain/use_cases/add_song_to_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/delete_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/get_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/remove_song_from_user_playlist_use_case.dart';
import 'package:music_app/features/library/domain/use_cases/update_user_playlist_use_case.dart';
import 'package:music_app/features/user_playlists/presentation/cubit/user_playlist_detail_cubit.dart';
import 'package:music_app/features/user_playlists/presentation/cubit/user_playlist_detail_state.dart';
import 'package:music_app/features/user_playlists/presentation/widgets/molecules/delete_playlist_dialog_molecule.dart';
import 'package:music_app/features/user_playlists/presentation/widgets/molecules/edit_playlist_dialog_molecule.dart';
import 'package:music_app/features/user_playlists/presentation/widgets/molecules/error_state_molecule.dart';
import 'package:music_app/features/user_playlists/presentation/widgets/molecules/playlist_not_found_molecule.dart';
import 'package:music_app/features/user_playlists/presentation/widgets/molecules/user_playlist_header_molecule.dart';
import 'package:music_app/features/user_playlists/presentation/widgets/organisms/add_songs_dialog_organism.dart';
import 'package:music_app/features/user_playlists/presentation/widgets/organisms/playlist_songs_list_organism.dart';
import 'package:music_app/features/user_playlists/presentation/widgets/organisms/user_playlist_detail_loading_organism.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class UserPlaylistDetailScreen extends StatelessWidget {
  final String playlistId;

  const UserPlaylistDetailScreen({
    @PathParam('id') required this.playlistId,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserPlaylistDetailCubit(
        getUserPlaylistUseCase: GetIt.I<GetUserPlaylistUseCase>(),
        updateUserPlaylistUseCase: GetIt.I<UpdateUserPlaylistUseCase>(),
        deleteUserPlaylistUseCase: GetIt.I<DeleteUserPlaylistUseCase>(),
        addSongToUserPlaylistUseCase: GetIt.I<AddSongToUserPlaylistUseCase>(),
        removeSongFromUserPlaylistUseCase:
            GetIt.I<RemoveSongFromUserPlaylistUseCase>(),
        playerBloc: context.read<PlayerBlocBloc>(),
      )..loadPlaylist(playlistId),
      child: _UserPlaylistDetailView(playlistId: playlistId),
    );
  }
}

class _UserPlaylistDetailView extends StatelessWidget {
  final String playlistId;

  const _UserPlaylistDetailView({required this.playlistId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserPlaylistDetailCubit, UserPlaylistDetailState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D0D0D),
          body: _buildBody(context, state),
          floatingActionButton: state.status == UserPlaylistDetailStatus.success
              ? FloatingActionButton(
                  onPressed: () => _showAddSongsDialog(context),
                  backgroundColor: AppColorsDark.primary,
                  child: const Icon(Icons.add, color: Colors.white),
                )
              : null,
        );
      },
    );
  }

  Future<void> _showAddSongsDialog(BuildContext context) async {
    final cubit = context.read<UserPlaylistDetailCubit>();

    await AddSongsDialogOrganism.show(
      context,
      onAddSong: (videoId, title, artist, thumbnail, duration) {
        cubit.addSongToPlaylist(
          playlistId: playlistId,
          videoId: videoId,
          title: title,
          artist: artist,
          thumbnail: thumbnail,
          duration: duration,
        );
      },
    );
  }

  Widget _buildBody(BuildContext context, UserPlaylistDetailState state) {
    switch (state.status) {
      case UserPlaylistDetailStatus.initial:
      case UserPlaylistDetailStatus.loading:
        return const UserPlaylistDetailLoadingOrganism();
      case UserPlaylistDetailStatus.failure:
        return ErrorStateMolecule(
          errorMessage: state.errorMessage,
          onRetry: () =>
              context.read<UserPlaylistDetailCubit>().loadPlaylist(playlistId),
        );
      case UserPlaylistDetailStatus.success:
        if (state.playlist == null) {
          return const PlaylistNotFoundMolecule();
        }
        return _buildPlaylistContent(context, state);
    }
  }

  Widget _buildPlaylistContent(
    BuildContext context,
    UserPlaylistDetailState state,
  ) {
    final playlist = state.playlist!;
    final cubit = context.read<UserPlaylistDetailCubit>();
    final l10n = AppLocalizations.of(context)!;

    return CustomScrollView(
      slivers: [
        UserPlaylistHeaderMolecule(
          playlistName: playlist.name,
          thumbnail: playlist.thumbnail,
          onEdit: (_) => EditPlaylistDialogMolecule.show(
            context,
            playlist.name,
            (newName) => cubit.updatePlaylist(playlistId, newName),
          ),
          onDelete: () => _confirmDelete(context, l10n),
        ),
        SliverToBoxAdapter(
          child: _PlaylistPlayButton(
            playlistId: playlistId,
            onPlayAll: cubit.playAll,
          ),
        ),
        PlaylistSongsListOrganism(
          songs: playlist.songs,
          onPlaySong: cubit.playSong,
        ),
      ],
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    AppLocalizations l10n,
  ) async {
    final cubit = context.read<UserPlaylistDetailCubit>();
    final confirmed = await DeletePlaylistDialogMolecule.show(context);

    if (confirmed == true && context.mounted) {
      await cubit.deletePlaylist(playlistId);
      if (context.mounted) {
        context.router.pop();
      }
    }
  }
}

class _PlaylistPlayButton extends StatelessWidget {
  final String playlistId;
  final VoidCallback onPlayAll;

  const _PlaylistPlayButton({
    required this.playlistId,
    required this.onPlayAll,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocSelector<
      PlayerBlocBloc,
      PlayerBlocState,
      ({String? sourceId, bool isPlaying, bool hasCurrentTrack})
    >(
      selector: (state) => (
        sourceId: state.sourceId,
        isPlaying: state.isPlaying,
        hasCurrentTrack: state.hasCurrentTrack,
      ),
      builder: (context, playerData) {
        final isCurrentPlaylist = playerData.sourceId == playlistId;
        final isPlaying = playerData.isPlaying;
        final hasCurrentTrack = playerData.hasCurrentTrack;

        return Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (isCurrentPlaylist && hasCurrentTrack) {
                    context.read<PlayerBlocBloc>().add(
                      const PlayPauseToggleEvent(),
                    );
                  } else {
                    onPlayAll();
                  }
                },
                icon: Icon(
                  isCurrentPlaylist && isPlaying
                      ? Icons.pause
                      : Icons.play_arrow,
                ),
                label: Text(
                  isCurrentPlaylist && isPlaying ? l10n.pause : l10n.play,
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColorsDark.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
