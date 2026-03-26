// ignore_for_file: avoid_dynamic_calls
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/playlist/domain/entities/playlist_track.dart';
import 'package:music_app/features/playlist/domain/use_cases/get_playlist_use_case.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_state.dart';
import 'package:music_app/features/playlist/presentation/widgets/atoms/empty_playlist_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/atoms/playlist_error_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/molecules/playlist_loading_widget.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/add_to_playlist_songs_bottom_sheet.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/playlist_listeners.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/playlist_menu_bottom_sheet.dart';
import 'package:music_app/features/playlist/presentation/widgets/organisms/playlist_scroll_content.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class PlaylistScreen extends StatefulWidget implements AutoRouteWrapper {
  final String id;

  const PlaylistScreen({required this.id, super.key});

  @override
  Widget wrappedRoute(BuildContext context) {
    return BlocProvider<PlaylistCubit>(
      create: (_) => PlaylistCubit(
        getPlaylistUseCase: GetIt.I<GetPlaylistUseCase>(),
        playerBloc: context.read<PlayerBlocBloc>(),
      ),
      child: this,
    );
  }

  @override
  State<PlaylistScreen> createState() => _PlaylistScreenState();
}

class _PlaylistScreenState extends State<PlaylistScreen> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool _showSearch = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.id.isNotEmpty) {
        context.read<PlaylistCubit>().loadPlaylist(widget.id);
      }
    });
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<PlaylistCubit>().loadMore();
    }
  }

  void _onSearchChanged() {
    context.read<PlaylistCubit>().filterPlaylist(_searchController.text);
  }

  void _toggleSearch() {
    setState(() {
      _showSearch = !_showSearch;
      if (!_showSearch) {
        _searchController.clear();
        context.read<PlaylistCubit>().filterPlaylist('');
      }
    });
  }

  Future<void> _onRefresh() async {
    if (widget.id.isNotEmpty) {
      await context.read<PlaylistCubit>().loadPlaylist(widget.id);
    }
  }

  void _showPlaylistMenu(BuildContext context, dynamic playlist) {
    final playlistState = context.read<PlaylistCubit>().state;
    final tracks = playlistState.allTracks.isNotEmpty
        ? playlistState.allTracks
        : playlistState.response?.tracks ?? [];

    PlaylistMenuBottomSheet.show(
      context: context,
      playlistTitle: playlist.title,
      onShare: () {},
      onAddToPlaylist: () => _showAddPlaylistSongsDialog(tracks.cast()),
      onShufflePlay: () => _shufflePlay(playlistState),
    );
  }

  void _shufflePlay(PlaylistState playlistState) {
    final tracks = playlistState.allTracks.isNotEmpty
        ? playlistState.allTracks
        : playlistState.response?.tracks ?? [];

    if (tracks.isEmpty) return;

    final validTracks = tracks
        .where(
          (track) =>
              track.videoId != null &&
              track.videoId!.isNotEmpty &&
              track.isAvailable &&
              track.streamUrl != null &&
              track.streamUrl!.isNotEmpty,
        )
        .toList();

    if (validTracks.isEmpty) return;

    validTracks.shuffle();

    final nowPlayingTracks = validTracks.map((track) {
      return NowPlayingData.fromPlaylistTrack(track);
    }).toList();

    context.read<PlayerBlocBloc>().add(
      LoadPlaylistEvent(
        playlist: nowPlayingTracks,
        startIndex: 0,
        sourceId: 'shuffle:${playlistState.response?.id}',
      ),
    );
  }

  void _showAddPlaylistSongsDialog(List<PlaylistTrack> tracks) {
    if (tracks.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(AppLocalizations.of(context)!.noSongsInPlaylist),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    AddToPlaylistSongsBottomSheet.show(context: context, tracks: tracks);
  }

  @override
  Widget build(BuildContext context) {
    final playerBloc = context.read<PlayerBlocBloc>();

    return PlaylistListeners(
      child: Scaffold(
        backgroundColor: AppColorsDark.surface,
        body: BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
          bloc: playerBloc,
          builder: (context, playerState) {
            return BlocBuilder<PlaylistCubit, PlaylistState>(
              builder: (context, playlistState) {
                if (playlistState.status == PlaylistStatus.loading ||
                    playlistState.status == PlaylistStatus.initial) {
                  return const PlaylistLoadingWidget();
                }

                if (playlistState.status == PlaylistStatus.failure) {
                  return PlaylistErrorWidget(
                    errorMessage:
                        playlistState.errorMessage ?? 'Error desconocido',
                    playlistId: widget.id,
                  );
                }

                final playlist = playlistState.response;
                if (playlist == null) {
                  return const EmptyPlaylistWidget();
                }

                return Stack(
                  children: [
                    PlaylistScrollContent(
                      playlist: playlist,
                      playlistState: playlistState,
                      scrollController: _scrollController,
                      searchController: _searchController,
                      showSearch: _showSearch,
                      onToggleSearch: _toggleSearch,
                      onSearchChanged: _onSearchChanged,
                      onLoadMore: () =>
                          context.read<PlaylistCubit>().loadMore(),
                      onRefresh: _onRefresh,
                      onShowMenu: _showPlaylistMenu,
                    ),
                  ],
                );
              },
            );
          },
        ),
      ),
    );
  }
}
