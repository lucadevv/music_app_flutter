import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/widgets/song_list_item.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:music_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/l10n/app_localizations.dart';
import 'package:music_app/main.dart';

/// Widget para mostrar canciones de radio (similares)
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar lista de canciones de radio basadas en la canción actual
class PlayerSimilarSongsWidget extends StatefulWidget {
  final String videoId;

  const PlayerSimilarSongsWidget({
    super.key,
    required this.videoId,
  });

  @override
  State<PlayerSimilarSongsWidget> createState() => _PlayerSimilarSongsWidgetState();
}

class _PlayerSimilarSongsWidgetState extends State<PlayerSimilarSongsWidget> {
  List<dynamic> _radioTracks = [];
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _loadRadioPlaylist();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }

  @override
  void didUpdateWidget(PlayerSimilarSongsWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoId != widget.videoId) {
      _loadRadioPlaylist();
    }
  }

  Future<void> _loadRadioPlaylist() async {
    if (_isDisposed) return;
    
    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final apiServices = getIt<ApiServices>();
      final response = await apiServices.get(
        '/music/radio/${widget.videoId}',
        queryParameters: {'limit': 10},
      );

      if (_isDisposed) return;
      
      final tracks = response.data['tracks'] as List<dynamic>? ?? [];

      if (mounted) {
        setState(() {
          _radioTracks = tracks;
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            l10n.songsSimilarToThis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 16),
        if (_isLoading)
          _buildLoadingState()
        else if (_error != null)
          _buildErrorState()
        else if (_radioTracks.isEmpty)
          _buildEmptyState()
        else
          _buildTracksList(),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Column(
      children: List.generate(
        4,
        (index) => const _SimilarSongItem(
          title: 'Loading...',
          artist: '',
          videoId: '',
          isLoading: true,
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        _error ?? 'Error loading radio',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'No similar songs found',
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTracksList() {
    return Column(
      children: _radioTracks.map((track) {
        final title = track['title'] ?? 'Unknown';
        final videoId = track['videoId'] ?? '';
        final artist = track['artists'] != null && (track['artists'] as List).isNotEmpty
            ? (track['artists'] as List).map((a) => a['name'] ?? 'Unknown').join(', ')
            : track['artist'] ?? 'Unknown Artist';
        final thumbnailUrl = track['thumbnail'];
        final streamUrl = track['stream_url'];
        final duration = track['length'] ?? '0:00';

        // Convert duration string to seconds for metadata
        int durationSeconds = 0;
        try {
          final parts = duration.split(':');
          if (parts.length == 2) {
            durationSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
          }
        } catch (_) {}

        return _SimilarSongItem(
          title: title,
          artist: artist,
          videoId: videoId,
          thumbnail: thumbnailUrl,
          durationSeconds: durationSeconds,
          onTap: () => _playTrack(
            videoId: videoId,
            title: title,
            artist: artist,
            thumbnailUrl: thumbnailUrl,
            streamUrl: streamUrl,
            duration: duration,
          ),
        );
      }).toList(),
    );
  }

  void _playTrack({
    required String videoId,
    required String title,
    required String artist,
    required String? thumbnailUrl,
    required String? streamUrl,
    required String duration,
  }) {
    // Convert duration string to seconds
    int durationSeconds = 0;
    try {
      final parts = duration.split(':');
      if (parts.length == 2) {
        durationSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      }
    } catch (_) {}

    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: videoId,
      title: title,
      artistNames: [artist],
      albumName: 'Radio',
      duration: duration,
      durationSeconds: durationSeconds,
      thumbnailUrl: thumbnailUrl,
      streamUrl: streamUrl,
    );

    context.read<PlayerBlocBloc>().add(LoadTrackEvent(nowPlayingData));
  }
}

class _SimilarSongItem extends StatelessWidget {
  final String title;
  final String artist;
  final String videoId;
  final String? thumbnail;
  final int? durationSeconds;
  final bool isLoading;
  final VoidCallback? onTap;

  const _SimilarSongItem({
    required this.title,
    required this.artist,
    required this.videoId,
    this.thumbnail,
    this.durationSeconds,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SongListItem(
      title: isLoading ? 'Loading...' : title,
      artist: isLoading ? '' : artist,
      thumbnail: thumbnail,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (videoId.isNotEmpty)
            FavoriteButton(
              videoId: videoId,
              type: FavoriteType.song,
              size: 22,
              metadata: SongMetadata(
                title: title,
                artist: artist,
                thumbnail: thumbnail,
                duration: durationSeconds,
              ),
            ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            onPressed: onTap,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
