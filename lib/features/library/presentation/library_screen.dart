// ignore_for_file: dead_code, dead_null_aware_expression, unused_element
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/data/offline/services/offline_service.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/features/library/presentation/widgets/templates/library_empty_state.dart';
import 'package:music_app/features/library/presentation/widgets/molecules/library_error_view.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/library_header.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/quick_access_section.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/library_loading_view.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/create_playlist_dialog.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/library_filtered_content.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';
import 'package:music_app/l10n/app_localizations.dart';

@RoutePage()
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // ProfileCubit es singleton proveído en app.dart
    // LibraryCubit se crea aquí con LibraryService como dependencia
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileCubit = context.read<ProfileCubit>();
      if (!profileCubit.state.isLoading && profileCubit.state.profile == null) {
        profileCubit.loadProfile();
      }
    });
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (ctx) => LibraryCubit(
            GetIt.I<LibraryService>(),
            GetIt.I<OfflineService>(),
            ctx.read<PlayerBlocBloc>(),
          )..loadLibrary(),
        ),
      ],
      child: const _LibraryView(),
    );
  }
}

class _LibraryView extends StatefulWidget {
  const _LibraryView();

  @override
  State<_LibraryView> createState() => _LibraryViewState();
}

class _LibraryViewState extends State<_LibraryView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      context.read<LibraryCubit>().loadMoreSongs();
    }
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.surface,
      body: SafeArea(
        child: BlocBuilder<LibraryCubit, LibraryState>(
          builder: (context, state) {
            return RefreshIndicator(
              color: Colors.white,
              backgroundColor: Colors.black54,
              onRefresh: () => context.read<LibraryCubit>().loadLibrary(),
              child: CustomScrollView(
                controller: _scrollController,
                physics: const AlwaysScrollableScrollPhysics(),
                slivers: <Widget>[
                  LibraryHeader(
                    searchController: _searchController,
                    onSearchChanged: _onSearchChanged,
                    onCreatePlaylist: () => _showCreatePlaylistDialog(context),
                  ),
                  if (state.status == LibraryStatus.loading)
                    const SliverFillRemaining(child: LibraryLoadingView())
                  else if (state.status == LibraryStatus.failure)
                    SliverFillRemaining(
                      child: LibraryErrorView(
                        errorMessage: state.errorMessage,
                        onRetry: () =>
                            context.read<LibraryCubit>().loadLibrary(),
                      ),
                    )
                  else ...[
                    QuickAccessSection(
                      totalSongs: state.totalSongs,
                      totalPlaylists: state.totalPlaylists,
                      totalGenres: state.totalGenres,
                    ),
                    if (state.favoritePlaylists.isNotEmpty ||
                        state.favoriteSongs.isNotEmpty)
                      LibraryFilteredContent(
                        searchQuery: _searchQuery,
                        allPlaylists: state.allPlaylists,
                        favoriteSongs: state.favoriteSongs,
                        onShowOptions: (song, l10n) =>
                            _showSongOptions(context, song, l10n),
                      ),
                    if (state.isEmpty && state.status == LibraryStatus.success)
                      SliverFillRemaining(
                        child: LibraryEmptyState(
                          message: 'Your library is empty',
                          onExplore: () {
                            context.tabsRouter.setActiveIndex(0);
                          },
                        ),
                      ),
                    const SliverToBoxAdapter(child: SizedBox(height: 120)),
                  ],
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSongOptions(
    BuildContext context,
    FavoriteSong song,
    AppLocalizations l10n,
  ) {
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
    final result = await CreatePlaylistDialog.show(context);

    if (result != null && result.isNotEmpty && context.mounted) {
      await context.read<LibraryCubit>().createPlaylist(result);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.createPlaylist}: $result'),
            backgroundColor: AppColorsDark.primary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
      }
    }
  }
}
