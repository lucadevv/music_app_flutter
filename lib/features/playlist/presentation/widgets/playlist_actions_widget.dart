import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/favorites/presentation/cubit/favorite_cubit.dart';
import 'package:music_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/playlist/domain/entities/playlist_response.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_cubit.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_state.dart';

/// Widget para los botones de acción de la playlist
class PlaylistActionsWidget extends StatelessWidget {
  final PlaylistResponse playlist;

  const PlaylistActionsWidget({required this.playlist, super.key});

  /// Obtiene la mejor thumbnail disponible
  String? _getBestThumbnail() {
    if (playlist.thumbnails.isEmpty) return null;

    // Ordenar por ancho y obtener la más grande
    final sortedThumbnails = List.of(playlist.thumbnails)
      ..sort((a, b) => b.width.compareTo(a.width));

    return sortedThumbnails.first.url;
  }

  bool _isPlaylistLoaded(PlayerBlocState playerState) {
    if (playerState is! PlayerBlocState) return false;
    if (playerState.playlist.isEmpty) return false;

    final currentPlaylistVideoIds = playlist.tracks
        .where(
          (track) =>
              track.videoId != null &&
              track.videoId!.isNotEmpty &&
              track.isAvailable,
        )
        .map((track) => track.videoId!)
        .toList();

    final loadedPlaylistVideoIds = playerState.playlist
        .where((track) => track.videoId.isNotEmpty)
        .map((track) => track.videoId)
        .toList();

    if (currentPlaylistVideoIds.length != loadedPlaylistVideoIds.length) {
      return false;
    }

    for (int i = 0; i < currentPlaylistVideoIds.length; i++) {
      if (currentPlaylistVideoIds[i] != loadedPlaylistVideoIds[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    final playerBloc = context.read<PlayerBlocBloc>();
    final playlistCubit = context.read<PlaylistCubit>();

    return BlocBuilder<PlaylistCubit, PlaylistState>(
      builder: (context, playlistState) {
        return BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
          builder: (context, playerState) {
            // Estado de carga del cubit
            final isLoadingForPlay = playlistState.isLoadingForPlay;
            final loadedCount = playlistState.loadedCount;
            final totalCount = playlistState.totalCount;

            // Determinar si está reproduciendo: 
            // Si hay currentTrack en el player, está reproduciendo o en pausa
            final hasCurrentTrack = playerState is PlayerBlocState &&
                playerState.currentTrack != null;
            final isPlaying = playerState is PlayerBlocState &&
                playerState.isPlaying;

            // El loading del botón solo cuando está cargando la primera
            final isLoadingFirstSong = isLoadingForPlay && loadedCount < 1;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  // Botón de play/pause
                  GestureDetector(
                    onTap: isLoadingFirstSong
                        ? null
                        : () {
                            // Si hay una canción (reproduciendo o pausa), togglear
                            if (hasCurrentTrack) {
                              playerBloc.add(const PlayPauseToggleEvent());
                            } else {
                              // No hay nada - cargar playlist desde cubit
                              playlistCubit.playAll();
                            }
                          },
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColorsDark.primary,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColorsDark.primary.withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: isLoadingFirstSong
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Icon(
                              isPlaying ? Icons.pause : Icons.play_arrow,
                              color: Colors.white,
                              size: 36,
                            ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Botón de favorito
                  FavoriteButton(
                    videoId: playlist.id,
                    type: FavoriteType.playlist,
                    size: 28,
                    playlistMetadata: PlaylistMetadata(
                      name: playlist.title,
                      thumbnail: _getBestThumbnail(),
                      description: playlist.description.isNotEmpty
                          ? playlist.description
                          : null,
                      trackCount: playlist.trackCount,
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Botón de descarga con progreso
                  _buildDownloadWithProgress(
                    isPlaylistLoading: isLoadingForPlay,
                    loadedCount: loadedCount,
                    totalToLoad: totalCount,
                  ),
                  const Spacer(),
                  // Botón de shuffle
                  IconButton(
                    icon: const Icon(Icons.shuffle, color: Colors.white, size: 28),
                    onPressed: () {},
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDownloadWithProgress({
    required bool isPlaylistLoading,
    int? loadedCount,
    int? totalToLoad,
  }) {
    // Si está cargando, mostrar progreso
    if (isPlaylistLoading && loadedCount != null && totalToLoad != null && totalToLoad > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColorsDark.primary.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '$loadedCount/$totalToLoad',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Si terminó de cargar, mostrar check
    if (loadedCount != null && totalToLoad != null && loadedCount >= totalToLoad && totalToLoad > 0) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.green.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: Colors.white, size: 16),
            SizedBox(width: 4),
            Text(
              'Lista',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    // Botón normal de descarga
    return IconButton(
      icon: const Icon(Icons.download, color: Colors.white, size: 28),
      onPressed: () {},
    );
  }
}
