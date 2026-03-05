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

  /// Verifica si la playlist actual es la que está reproduciéndose
  bool _isCurrentPlaylistPlaying(PlayerBlocState playerState) {
    if (playerState.playlist.isEmpty) return false;
    if (playerState.currentTrack == null) return false;

    // Verificar si el videoId del track actual está en esta playlist
    final currentVideoId = playerState.currentTrack?.videoId;
    if (currentVideoId == null) return false;
    
    return playlist.tracks.any((track) => track.videoId == currentVideoId);
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

            // Verificar si la playlist actual está reproduciéndose
            final isCurrentPlaylist = _isCurrentPlaylistPlaying(playerState);
            final hasCurrentTrack = playerState.currentTrack != null;
            final isPlaying = playerState.isPlaying;

            // El botón muestra:
            // - Loading si está cargando la primera canción
            // - Play si no hay canción reproduciéndose O si es otra playlist
            // - Pause si es la misma playlist y está reproduciéndose
            final isLoadingFirstSong = isLoadingForPlay && loadedCount < 1;
            final showPause = isCurrentPlaylist && isPlaying;

            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
              child: Row(
                children: [
                  // Botón de play/pause
                  GestureDetector(
                    onTap: isLoadingFirstSong
                        ? null
                        : () {
                            // Si es la misma playlist y hay algo reproducido, togglear
                            if (isCurrentPlaylist && hasCurrentTrack) {
                              playerBloc.add(const PlayPauseToggleEvent());
                            } else {
                              // Es otra playlist o no hay nada - cargar esta playlist
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
                              showPause ? Icons.pause : Icons.play_arrow,
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
}
