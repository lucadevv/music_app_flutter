import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/dashboard/presentation/bloc/player_bloc_bloc.dart';
import 'package:music_app/features/playlist/data/isolates/playlist_processing_isolate.dart';
import 'package:music_app/features/playlist/domain/entities/playlist_response.dart';
import 'package:music_app/main.dart';

/// Widget para los botones de acción de la playlist
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar y manejar los botones de acción
class PlaylistActionsWidget extends StatelessWidget {
  final PlaylistResponse playlist;

  const PlaylistActionsWidget({
    super.key,
    required this.playlist,
  });

  /// Verifica si la playlist actual está cargada en el PlayerBloc
  /// Compara los videoIds de la playlist con los de la playlist cargada
  bool _isPlaylistLoaded(PlayerBlocState playerState) {
    if (playerState is! PlayerBlocLoaded) return false;
    if (playerState.playlist.isEmpty) return false;

    // Obtener videoIds de la playlist actual
    final currentPlaylistVideoIds = playlist.tracks
        .where((track) =>
            track.videoId != null &&
            track.videoId!.isNotEmpty &&
            track.isAvailable)
        .map((track) => track.videoId!)
        .toList();

    // Obtener videoIds de la playlist cargada
    final loadedPlaylistVideoIds = playerState.playlist
        .where((track) => track.videoId != null && track.videoId!.isNotEmpty)
        .map((track) => track.videoId!)
        .toList();

    // Verificar si tienen la misma cantidad y los mismos videoIds
    if (currentPlaylistVideoIds.length != loadedPlaylistVideoIds.length) {
      return false;
    }

    // Comparar que todos los videoIds coincidan
    for (int i = 0; i < currentPlaylistVideoIds.length; i++) {
      if (currentPlaylistVideoIds[i] != loadedPlaylistVideoIds[i]) {
        return false;
      }
    }

    return true;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
      bloc: getIt<PlayerBlocBloc>(),
      builder: (context, playerState) {
        final isLoadingPlaylist =
            playerState is PlayerBlocLoaded &&
            playerState.isLoading &&
            playerState.playlist.isNotEmpty;

        final isPlaylistLoaded = _isPlaylistLoaded(playerState);
        final isPlaying = playerState is PlayerBlocLoaded &&
            isPlaylistLoaded &&
            playerState.isPlaying;

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Row(
            children: [
              // Botón de play/pause
              GestureDetector(
                onTap: isLoadingPlaylist
                    ? null
                    : () async {
                        if (isPlaylistLoaded) {
                          // Si la playlist ya está cargada, solo toggle play/pause
                          getIt<PlayerBlocBloc>().add(
                            const PlayPauseToggleEvent(),
                          );
                        } else {
                          // Si la playlist no está cargada, cargarla
                          final availableTracks = playlist.tracks
                              .where(
                                (track) =>
                                    track.videoId != null &&
                                    track.videoId!.isNotEmpty &&
                                    track.isAvailable,
                              )
                              .toList();

                          if (availableTracks.isEmpty) return;

                          // Usar isolate para playlists grandes
                          final tracks =
                              await PlaylistProcessingIsolate.processPlaylistInIsolate(
                            availableTracks,
                          );

                          if (tracks.isNotEmpty && context.mounted) {
                            getIt<PlayerBlocBloc>().add(
                              LoadPlaylistEvent(
                                playlist: tracks,
                                startIndex: 0,
                              ),
                            );
                          }
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
                  child: isLoadingPlaylist
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
              IconButton(
                icon: const Icon(
                  Icons.favorite_border,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),
              // Botón de descarga
              IconButton(
                icon: const Icon(
                  Icons.download,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),
              const Spacer(),
              // Botón de shuffle
              IconButton(
                icon: const Icon(
                  Icons.shuffle,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),
            ],
          ),
        );
      },
    );
  }
}
