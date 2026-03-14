// ignore_for_file: use_late_for_private_fields_and_variables, avoid_dynamic_calls
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/home/presentation/widgets/organisms/home_shimmer.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/domain/usecases/get_radio_playlist_usecase.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Widget para mostrar canciones de radio (similares)
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar lista de canciones de radio basadas en la canción actual
class PlayerSimilarSongsWidget extends StatefulWidget {
  final String videoId;

  const PlayerSimilarSongsWidget({required this.videoId, super.key});

  @override
  State<PlayerSimilarSongsWidget> createState() =>
      _PlayerSimilarSongsWidgetState();
}

class _PlayerSimilarSongsWidgetState extends State<PlayerSimilarSongsWidget> {
  late final GetRadioPlaylistUseCase _getRadioPlaylistUseCase;
  List<dynamic> _radioTracks = [];
  bool _isLoading = true;
  String? _error;
  bool _isDisposed = false;
//   String? _currentLoadingVideoId; // Track which videoId is being loaded

  @override
  void initState() {
    super.initState();
    _getRadioPlaylistUseCase = GetIt.I<GetRadioPlaylistUseCase>();
//     _currentLoadingVideoId = widget.videoId;
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
      // Reset state immediately for new videoId
//       _currentLoadingVideoId = widget.videoId;
      _radioTracks = [];
      _error = null;
      _isLoading = true;
      _loadRadioPlaylist();
    }
  }

  Future<void> _loadRadioPlaylist() async {
    if (_isDisposed) return;
    
    // Guardar el videoId actual que se va a cargar
    final loadingVideoId = widget.videoId;
    
    // No cargar si el videoId está vacío
    if (loadingVideoId.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _radioTracks = [];
        });
      }
      return;
    }

    if (mounted) {
      setState(() {
        _isLoading = true;
        _error = null;
      });
    }

    try {
      final tracks = await _getRadioPlaylistUseCase(loadingVideoId, limit: 10);

      if (_isDisposed) return;
      
      // Verificar que el videoId sigue siendo el mismo antes de actualizar
      if (widget.videoId != loadingVideoId) {
        // El videoId cambió mientras cargábamos, ignorar esta respuesta
        return;
      }

      if (mounted) {
        setState(() {
          _radioTracks = tracks;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (_isDisposed) return;
      
      // Verificar que el videoId sigue siendo el mismo
      if (widget.videoId != loadingVideoId) {
        return;
      }

      // Ignorar errores de cancelación/interrupción de conexión
      final errorString = e.toString().toLowerCase();
      final isIgnorableError = 
          errorString.contains('cancelled') ||
          errorString.contains('interrupted') ||
          errorString.contains('loading interrupted') ||
          errorString.contains('connection') && errorString.contains('closed') ||
          errorString.contains('socketexception') ||
          errorString.contains('timeout') ||
          errorString.contains('resetear player') ||
          errorString.contains('bad response') ||
          errorString.contains('500') ||
          errorString.contains('502') ||
          errorString.contains('503') ||
          errorString.contains('dioexception');
      
      if (isIgnorableError) {
        // No mostrar error al usuario, simplemente cargar en silencio
        if (mounted) {
          setState(() {
            _isLoading = false;
            _radioTracks = [];
          });
        }
        return;
      }

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
        Padding(
          padding: const EdgeInsets.only(left: 16),
          child: Align(
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
        (index) => const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: SongListItemsShimmer(),
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
        final artist =
            track['artists'] != null && (track['artists'] as List).isNotEmpty
            ? (track['artists'] as List)
                  .map((a) => a['name'] ?? 'Unknown')
                  .join(', ')
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
    // Convert duration string to seconds (handles "M:SS" and "H:MM:SS" formats)
    int durationSeconds = 0;
    try {
      final parts = duration.split(':');
      if (parts.length == 2) {
        durationSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      } else if (parts.length == 3) {
        durationSeconds = int.parse(parts[0]) * 3600 + int.parse(parts[1]) * 60 + int.parse(parts[2]);
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

    context.read<PlayerBlocBloc>().add(LoadTrackEvent(nowPlayingData, sourceId: 'radio'));
  }
}

// Removed _parseDurationToSeconds as it was unused

class _SimilarSongItem extends StatelessWidget {
  final String title;
  final String artist;
  final String videoId;
  final String? thumbnail;
  final int? durationSeconds;
  final VoidCallback? onTap;

  const _SimilarSongItem({
    required this.title,
    required this.artist,
    required this.videoId,
    this.thumbnail,
    this.durationSeconds,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {

    final durationText = _formatDuration(durationSeconds);

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 4),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: Container(
          width: 48,
          height: 48,
          color: AppColorsDark.primaryContainer,
          child: thumbnail != null
              ? CachedNetworkImage(
                  imageUrl: thumbnail!,
                  fit: BoxFit.cover,
                  errorWidget: (context, url, error) =>
                      const Icon(Icons.music_note, color: AppColorsDark.primary),
                )
              : const Icon(Icons.music_note, color: AppColorsDark.primary),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: durationText != null
          ? Text(
              durationText,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  String? _formatDuration(int? seconds) {
    if (seconds == null || seconds == 0) return null;
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
