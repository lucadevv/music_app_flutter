import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/song_list_item.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class UserPlaylistDetailScreen extends StatefulWidget {
  final String playlistId;
  
  const UserPlaylistDetailScreen({
    super.key,
    @PathParam('id') required this.playlistId,
  });

  @override
  State<UserPlaylistDetailScreen> createState() => _UserPlaylistDetailScreenState();
}

class _UserPlaylistDetailScreenState extends State<UserPlaylistDetailScreen> {
  UserPlaylistDetail? _playlist;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadPlaylist();
  }

  Future<void> _loadPlaylist() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final libraryService = getIt<LibraryService>();
      final response = await libraryService.getUserPlaylist(widget.playlistId);
      
      if (mounted) {
        setState(() {
          _playlist = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  void _playSong(int index) {
    if (_playlist == null || _playlist!.songs.isEmpty) return;

    final playlist = _playlist!.songs.map((s) => NowPlayingData.fromBasic(
      videoId: s.videoId,
      title: s.title,
      artistNames: [s.artist],
      albumName: '',
      duration: s.duration != null ? _formatDuration(s.duration!) : '0:00',
      durationSeconds: s.duration,
      thumbnailUrl: s.thumbnail,
    )).toList();

    getIt<PlayerBlocBloc>().add(LoadPlaylistEvent(
      playlist: playlist,
      startIndex: index,
    ));
    context.router.push(PlayerRoute(nowPlayingData: playlist.first));
  }

  void _playAll() {
    _playSong(0);
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '$minutes:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColorsDark.primary))
          : _error != null
              ? _buildError(l10n)
              : _buildContent(l10n),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(_error!, style: const TextStyle(color: Colors.white70)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPlaylist,
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(AppLocalizations l10n) {
    return CustomScrollView(
      slivers: [
        _buildHeader(l10n),
        _buildSongsList(l10n),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations l10n) {
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
          onPressed: () => _showOptions(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColorsDark.primaryContainer,
                const Color(0xFF0D0D0D),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Playlist cover
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: AppColorsDark.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: _playlist?.thumbnail != null
                          ? CachedNetworkImage(
                              imageUrl: _playlist!.thumbnail!,
                              fit: BoxFit.cover,
                            )
                          : Icon(
                              Icons.playlist_play,
                              size: 48,
                              color: AppColorsDark.primary.withValues(alpha: 0.7),
                            ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Title
                  Text(
                    _playlist?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Song count
                  Text(
                    '${_playlist?.songs.length ?? 0} ${l10n.songs}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Play button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: _playAll,
                        child: Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: AppColorsDark.primary,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSongsList(AppLocalizations l10n) {
    if (_playlist == null || _playlist!.songs.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.music_note,
                size: 64,
                color: Colors.white.withValues(alpha: 0.3),
              ),
              const SizedBox(height: 16),
              Text(
                'No songs yet',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Add songs from the library',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = _playlist!.songs[index];
          return SongListItemWithRemove(
            title: song.title,
            artist: song.artist,
            thumbnail: song.thumbnail,
            onTap: () => _playSong(index),
            onRemove: () => _removeSong(song.id),
          );
        },
        childCount: _playlist!.songs.length,
      ),
    );
  }

  void _showOptions(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColorsDark.surfaceContainerHigh,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          top: 16,
          bottom: MediaQuery.of(context).padding.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit, color: Colors.white),
              title: Text(l10n.edit, style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
                _showEditDialog(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
              onTap: () {
                Navigator.pop(context);
                _confirmDelete(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final nameController = TextEditingController(text: _playlist?.name);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(l10n.edit, style: const TextStyle(color: Colors.white)),
        content: TextField(
          controller: nameController,
          style: const TextStyle(color: Colors.white),
          decoration: InputDecoration(
            labelText: l10n.playlistName,
            labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _updatePlaylist(nameController.text);
            },
            child: Text(l10n.save, style: const TextStyle(color: AppColorsDark.primary)),
          ),
        ],
      ),
    );
  }

  Future<void> _updatePlaylist(String name) async {
    try {
      final libraryService = getIt<LibraryService>();
      await libraryService.updateUserPlaylist(widget.playlistId, name: name);
      _loadPlaylist();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  void _confirmDelete(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        title: Text(l10n.delete, style: const TextStyle(color: Colors.white)),
        content: Text(
          '¿Delete "${_playlist?.name}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deletePlaylist();
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _deletePlaylist() async {
    try {
      final libraryService = getIt<LibraryService>();
      await libraryService.deleteUserPlaylist(widget.playlistId);
      if (mounted) {
        context.router.pop();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  Future<void> _removeSong(String songId) async {
    try {
      final libraryService = getIt<LibraryService>();
      await libraryService.removeSongFromUserPlaylist(widget.playlistId, songId);
      _loadPlaylist();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }
}
