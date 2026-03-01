import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/core/widgets/song_list_item.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

@RoutePage()
class RecentlyPlayedScreen extends StatefulWidget {
  const RecentlyPlayedScreen({super.key});

  @override
  State<RecentlyPlayedScreen> createState() => _RecentlyPlayedScreenState();
}

class _RecentlyPlayedScreenState extends State<RecentlyPlayedScreen> {
  List<dynamic> _songs = [];
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadRecentlyPlayed();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  Future<void> _loadRecentlyPlayed() async {
    if (_isDisposed) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final apiServices = getIt<ApiServices>();
      final response = await apiServices.get('/music/recently-listened');

      if (_isDisposed) return;

      final songs = response.data['songs'] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _songs = songs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (_isDisposed) return;

      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      body: CustomScrollView(
        slivers: [
          _buildHeader(context, l10n),
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColorsDark.primary),
              ),
            )
          else if (_error != null)
            SliverFillRemaining(
              child: _buildError(l10n),
            )
          else if (_songs.isEmpty)
            SliverFillRemaining(
              child: _buildEmpty(l10n),
            )
          else
            _buildSongsList(context, l10n),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, AppLocalizations l10n) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => context.router.maybePop(),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white),
          onPressed: () {},
        ),
        IconButton(
          icon: const Icon(Icons.more_vert, color: Colors.white),
          onPressed: () {},
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
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColorsDark.primary,
                          AppColorsDark.secondary,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.history,
                      size: 60,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    l10n.recentlyPlayed,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${_songs.length} ${l10n.songs}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }

  Widget _buildSongsList(BuildContext context, AppLocalizations l10n) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final song = _songs[index];
          return _SongItem(
            song: song,
            onTap: () => _playSong(context, song),
          );
        },
        childCount: _songs.length,
      ),
    );
  }

  Widget _buildError(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 48),
          const SizedBox(height: 16),
          Text(
            _error ?? l10n.errorLoadingSongs,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadRecentlyPlayed,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsDark.primary,
            ),
            child: Text(l10n.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildEmpty(AppLocalizations l10n) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.white.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.noRecentlyPlayed,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.songsYouListenToWillAppearHere,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.5),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _playSong(BuildContext context, dynamic song) {
    final videoId = song['videoId'] ?? '';
    final title = song['title'] ?? 'Unknown';
    final artist = song['artist'] ?? 'Unknown Artist';
    final thumbnail = song['thumbnail'];
    final durationStr = song['duration'] ?? '0:00';

    // Convert duration string to seconds
    int durationSeconds = 0;
    try {
      final parts = durationStr.toString().split(':');
      if (parts.length == 2) {
        durationSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
    } catch (_) {}

    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: videoId.toString(),
      title: title.toString(),
      artistNames: [artist.toString()],
      albumName: '',
      duration: durationStr.toString(),
      durationSeconds: durationSeconds,
      thumbnailUrl: thumbnail?.toString(),
    );

    getIt<PlayerBlocBloc>().add(LoadTrackEvent(nowPlayingData));
    context.router.push(PlayerRoute(nowPlayingData: nowPlayingData));
  }
}

class _SongItem extends StatelessWidget {
  final dynamic song;
  final VoidCallback onTap;

  const _SongItem({
    required this.song,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = song['title'] ?? 'Unknown';
    final artist = song['artist'] ?? 'Unknown Artist';
    final thumbnail = song['thumbnail'];

    return SongListItemWithTrailing(
      title: title.toString(),
      artist: artist.toString(),
      thumbnail: thumbnail?.toString(),
      trailing: Icon(
        Icons.play_circle_outline,
        color: Colors.white.withValues(alpha: 0.6),
      ),
      onTap: onTap,
    );
  }
}
