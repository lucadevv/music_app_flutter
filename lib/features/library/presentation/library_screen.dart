// ignore_for_file: dead_code, dead_null_aware_expression, unused_element
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/utils/extension/sizedbox_extension.dart';
import 'package:music_app/core/widgets/custom_search_bar.dart';
import 'package:music_app/core/widgets/shimmer_widgets.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/features/library/presentation/widgets/atoms/profile_avatar.dart';
import 'package:music_app/features/library/presentation/widgets/molecules/playlist_card.dart';
import 'package:music_app/features/library/presentation/widgets/molecules/quick_access_chip.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/song_list_item_widget.dart';
import 'package:music_app/features/library/presentation/widgets/templates/library_empty_state.dart';
import 'package:music_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // LibraryCubit es factory, así que puede crear nuevas instancias
    // ProfileCubit es singleton, así que se usa BlocProvider.value del padre (app.dart)
    // Cargar perfil al entrar si no está cargado
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final profileCubit = context.read<ProfileCubit>();
      if (!profileCubit.state.isLoading && profileCubit.state.profile == null) {
        profileCubit.loadProfile();
      }
    });
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<LibraryCubit>()..loadLibrary()),
        // ProfileCubit ya está proporcionado en app.dart como singleton
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
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value.toLowerCase();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: AppColorsDark.surface,
      body: SafeArea(
        child: BlocBuilder<LibraryCubit, LibraryState>(
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
                      child: _LibraryLoadingView(),
                    )
                  else if (state.status == LibraryStatus.failure)
                    SliverFillRemaining(
                      child: _buildError(state.errorMessage, context, l10n),
                    )
                  else ...[
                    // Filtrar playlists si hay búsqueda
                    _buildQuickAccess(context, state, l10n),
                    if (state.favoritePlaylists.isNotEmpty || state.favoriteSongs.isNotEmpty)
                      _buildFilteredContent(context, state, l10n),
                    if (state.isEmpty && state.status == LibraryStatus.success)
                      SliverFillRemaining(
                        child: LibraryEmptyState(
                          l10n: l10n,
                          onExplore: () {
                            // Navegar al tab de home (índice 0)
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

  Widget _buildFilteredContent(BuildContext context, LibraryState state, AppLocalizations l10n) {
    // Usar allPlaylists que tiene isUserCreated
    final allPlaylists = state.allPlaylists;
    
    // Filtrar playlists
    final filteredPlaylists = _searchQuery.isEmpty
        ? allPlaylists
        : allPlaylists.where((p) {
            final name = p.name.toLowerCase() ?? '';
            return name.contains(_searchQuery);
          }).toList();

    // Filtrar songs
    final filteredSongs = _searchQuery.isEmpty
        ? state.favoriteSongs
        : state.favoriteSongs.where((s) {
            final title = s.title.toLowerCase() ?? '';
            final artist = s.artist.toLowerCase() ?? '';
            return title.contains(_searchQuery) || artist.contains(_searchQuery);
          }).toList();

    // Mostrar mensaje si no hay resultados
    if (_searchQuery.isNotEmpty && filteredPlaylists.isEmpty && filteredSongs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No results for "$_searchQuery"',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Return SliverToBoxAdapter with all content instead of SliverList
    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (filteredPlaylists.isNotEmpty)
            _buildPlaylistsSectionFiltered(context, filteredPlaylists, l10n),
          if (filteredSongs.isNotEmpty)
            _buildSongsSectionFiltered(context, filteredSongs, l10n),
            60.spaceh,
            
        ],
      ),
    );
  }

  Widget _buildPlaylistsSectionFiltered(
    BuildContext context,
    List<PlaylistItem> playlists,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.playlists,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 200,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: playlists.length > 10 ? 10 : playlists.length,
            itemBuilder: (context, index) {
              final playlist = playlists[index];
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: PlaylistCard(
                  playlist: playlist,
                  onTap: () {
                    if (playlist.isUserCreated) {
                      context.router.push(
                        UserPlaylistDetailRoute(playlistId: playlist.id),
                      );
                    } else if (playlist.externalPlaylistId != null) {
                      context.router.push(
                        PlaylistRoute(id: playlist.externalPlaylistId!),
                      );
                    }
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongsSectionFiltered(
    BuildContext context,
    List<FavoriteSong> songs,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Text(
            l10n.likedSongs,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: songs.length > 10 ? 10 : songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return SongListItemWidget(
              song: song,
              onTap: () {
                final nowPlayingData = context.read<LibraryCubit>().playSong(song);
                context.router.push(
                  PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: true),
                );
              },
              onOptionsTap: () => _showSongOptions(context, song, l10n),
            );
          },
        ),
      ],
    );
  }

  SliverToBoxAdapter _buildHeader(BuildContext context, AppLocalizations l10n) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  l10n.yourLibrary,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Row(
                  children: [
                    BlocBuilder<ProfileCubit, ProfileState>(
                      builder: (context, profileState) {
                        return GestureDetector(
                          onTap: () => context.router.push(const MyProfileRoute()),
                          child: ProfileAvatar(
                            avatarUrl: profileState.avatarUrl,
                            initials: profileState.initials.isNotEmpty 
                                ? profileState.initials 
                                : 'U',
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    PopupMenuButton<String>(
                      icon: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E1E26),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.add,
                          color: Colors.white.withValues(alpha: 0.8),
                          size: 20,
                        ),
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
                              Icon(
                                Icons.playlist_add,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
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
                ),
              ],
            ),
            const SizedBox(height: 24),
            CustomSearchBar(
              hintText: l10n.searchFor,
              controller: _searchController,
              onChanged: _onSearchChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(
    String? errorMessage,
    BuildContext context,
    AppLocalizations l10n,
  ) {
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
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Quick Access',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.playlists,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (state.totalPlaylists > 5)
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: state.allPlaylists.length > 10
                  ? 10
                  : state.allPlaylists.length,
              itemBuilder: (context, index) {
                final playlist = state.allPlaylists[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: PlaylistCard(
                    playlist: playlist,
                    onTap: () {
                      if (playlist.isUserCreated) {
                        context.router.push(
                          UserPlaylistDetailRoute(playlistId: playlist.id),
                        );
                      } else if (playlist.externalPlaylistId != null) {
                        context.router.push(
                          PlaylistRoute(id: playlist.externalPlaylistId!),
                        );
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
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  l10n.likedSongs,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Poppins',
                  ),
                ),
                if (state.totalSongs > 5)
                  Icon(
                    Icons.chevron_right,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
              ],
            ),
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: state.favoriteSongs.length > 10
                ? 10
                : state.favoriteSongs.length,
            itemBuilder: (context, index) {
              final song = state.favoriteSongs[index];
                return SongListItemWidget(
                 song: song,
                 onTap: () {
                   final nowPlayingData = context.read<LibraryCubit>().playSong(
                     song,
                   );
                   context.router.push(
                     PlayerRoute(nowPlayingData: nowPlayingData, playAsSingle: true),
                   );
                 },
                onOptionsTap: () => _showSongOptions(context, song, l10n),
              );
            },
          ),
        ],
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
    final nameController = TextEditingController();

    final result = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          l10n.createPlaylist,
          style: const TextStyle(color: Colors.white, fontFamily: 'Poppins'),
        ),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            hintText: l10n.playlistName,
            hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
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

/// Widget de loading con shimmer para LibraryScreen
class _LibraryLoadingView extends StatelessWidget {
  const _LibraryLoadingView();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Quick access shimmer
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const TextShimmer(width: 140, height: 24),
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(4, (index) {
                 // Clone real dimensions of QuickAccessChip
                 return Container(
                    width: (MediaQuery.of(context).size.width - 48) / 2,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColorsDark.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                 );
              }),
            ),
          ),
          const SizedBox(height: 32),
          
          // Playlists section shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextShimmer(width: 100, height: 24),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: 4,
              itemBuilder: (context, index) {
                return const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Column(
                    children: [
                      ThumbnailShimmer(width: 156, height: 156),
                      SizedBox(height: 8),
                      TextShimmer(width: 120, height: 16),
                      SizedBox(height: 4),
                      TextShimmer(width: 60, height: 12),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 32),
          
          // Songs section shimmer
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: TextShimmer(width: 120, height: 24),
          ),
          const SizedBox(height: 16),
          const SongListItemShimmer(),
          const SongListItemShimmer(),
          const SongListItemShimmer(),
        ],
      ),
    );
  }
}
