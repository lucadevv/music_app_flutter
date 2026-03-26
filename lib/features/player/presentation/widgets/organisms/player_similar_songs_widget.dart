import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/core/services/network/api_services.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/home/presentation/widgets/organisms/home_shimmer.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/player/domain/usecases/get_radio_playlist_usecase.dart';
import 'package:music_app/features/player/presentation/cubit/similar_songs/similar_songs_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Widget para mostrar canciones de radio (similares)
///
/// Refactorizado arquitectónicamente para delegar al Cubit.
class PlayerSimilarSongsWidget extends StatelessWidget {
  final String videoId;

  const PlayerSimilarSongsWidget({required this.videoId, super.key});

  @override
  Widget build(BuildContext context) {
    if (videoId.isEmpty) return const SizedBox.shrink();

    return BlocProvider(
      key: ValueKey(videoId),
      create: (_) =>
          SimilarSongsCubit(GetIt.I<GetRadioPlaylistUseCase>())
            ..loadSimilarSongs(videoId),
      child: const _PlayerSimilarSongsContent(),
    );
  }
}

class _PlayerSimilarSongsContent extends StatelessWidget {
  const _PlayerSimilarSongsContent();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return BlocBuilder<SimilarSongsCubit, SimilarSongsState>(
      builder: (context, state) {
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
                    color: AppColorsDark.onSurface,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (state.status == SimilarSongsStatus.loading ||
                state.status == SimilarSongsStatus.initial)
              _buildLoadingState()
            else if (state.status == SimilarSongsStatus.failure)
              _buildErrorState(state.error)
            else if (state.tracks.isEmpty)
              _buildEmptyState()
            else
              _buildTracksList(context, state),
          ],
        );
      },
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

  Widget _buildErrorState(String? error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        error ?? 'Error loading radio',
        style: TextStyle(
          color: AppColorsDark.onSurface.withValues(alpha: 0.6),
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
          color: AppColorsDark.onSurface.withValues(alpha: 0.6),
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _buildTracksList(BuildContext context, SimilarSongsState state) {
    return Column(
      children: state.tracks.map((track) {
        return _SimilarSongItem(
          title: track.title,
          artist: track.displayArtist,
          videoId: track.videoId,
          thumbnail: track.thumbnail,
          durationSeconds: track.durationSeconds,
          onTap: () => _playTrack(
            context: context,
            videoId: track.videoId,
            title: track.title,
            artist: track.displayArtist,
            thumbnailUrl: track.thumbnail,
            streamUrl: track.streamUrl,
            duration: track.length ?? '0:00',
          ),
        );
      }).toList(),
    );
  }

  Future<void> _playTrack({
    required BuildContext context,
    required String videoId,
    required String title,
    required String artist,
    required String? thumbnailUrl,
    required String? streamUrl,
    required String duration,
  }) async {
    int durationSeconds = 0;
    try {
      final parts = duration.split(':');
      if (parts.length == 2) {
        durationSeconds = int.parse(parts[0]) * 60 + int.parse(parts[1]);
      } else if (parts.length == 3) {
        durationSeconds =
            int.parse(parts[0]) * 3600 +
            int.parse(parts[1]) * 60 +
            int.parse(parts[2]);
      }
    } catch (_) {}

    String? resolvedStreamUrl = streamUrl;
    if (resolvedStreamUrl == null || resolvedStreamUrl.isEmpty) {
      resolvedStreamUrl = await _fetchStreamUrl(videoId);
    }

    final nowPlayingData = NowPlayingData.fromBasic(
      videoId: videoId,
      title: title,
      artistNames: [artist],
      albumName: 'Radio',
      duration: duration,
      durationSeconds: durationSeconds,
      thumbnailUrl: thumbnailUrl,
      streamUrl: resolvedStreamUrl,
    );

    if (context.mounted) {
      context.read<PlayerBlocBloc>().add(
        LoadTrackEvent(nowPlayingData, sourceId: 'radio'),
      );
    }
  }

  Future<String?> _fetchStreamUrl(String videoId) async {
    try {
      final apiServices = GetIt.I.get<ApiServices>();
      final response = await apiServices.get('/music/stream/$videoId');
      // ignore: avoid_dynamic_calls
      final data = response is Map ? response : (response.data as Map?);
      return data?['streamUrl'] as String?;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error fetching streamUrl: $e');
      }
      return null;
    }
  }
}

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
                  errorWidget: (context, url, error) => const Icon(
                    Icons.music_note,
                    color: AppColorsDark.primary,
                  ),
                )
              : const Icon(Icons.music_note, color: AppColorsDark.primary),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColorsDark.onSurface,
          fontSize: 15,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        artist,
        style: TextStyle(
          color: AppColorsDark.onSurface.withValues(alpha: 0.6),
          fontSize: 13,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: durationText != null
          ? Text(
              durationText,
              style: TextStyle(
                color: AppColorsDark.onSurface.withValues(alpha: 0.6),
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
