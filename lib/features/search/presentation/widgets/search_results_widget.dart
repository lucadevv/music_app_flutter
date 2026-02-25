import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import '../../domain/entities/song.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<Song> results;

  const SearchResultsWidget({super.key, required this.results});

  @override
  Widget build(BuildContext context) {
    if (results.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Text(
            'No se encontraron resultados',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: results.length,
      itemBuilder: (context, index) {
        final song = results[index];
        return _SongItem(song: song);
      },
    );
  }
}

class _SongItem extends StatelessWidget {
  final Song song;

  const _SongItem({required this.song});

  @override
  Widget build(BuildContext context) {
    // Obtener la mejor thumbnail (la más grande disponible)
    final thumbnail = song.thumbnails.isNotEmpty
        ? song.thumbnails.last
        : null; // Usar la última que suele ser la más grande

    // Obtener nombres de artistas
    final artistsNames = song.artists.map((a) => a.name).join(', ');

    return GestureDetector(
      onTap: () {
        context.router.push(
          PlayerRoute(
            nowPlayingData: NowPlayingData.fromSong(song),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
            // Thumbnail con Hero animation
            Hero(
              tag: 'song_artwork_${song.videoId}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: thumbnail != null
                    ? CachedNetworkImage(
                        imageUrl: thumbnail.url,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Container(
                          width: 60,
                          height: 60,
                          color: AppColorsDark.primaryContainer,
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColorsDark.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: AppColorsDark.primaryContainer,
                          child: Icon(
                            Icons.music_note,
                            color: AppColorsDark.primary,
                          ),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: AppColorsDark.primaryContainer,
                        child: Icon(
                          Icons.music_note,
                          color: AppColorsDark.primary,
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 16),
            // Información de la canción
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    song.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$artistsNames • ${song.album.name}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${song.duration} • ${song.views}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            // Botón de más opciones
            IconButton(
              icon: Icon(
                Icons.more_vert,
                color: Colors.white.withValues(alpha: 0.5),
              ),
              onPressed: () {
                // TODO: Mostrar menú de opciones
              },
            ),
          ],
        ),
      ),
    );
  }
}
