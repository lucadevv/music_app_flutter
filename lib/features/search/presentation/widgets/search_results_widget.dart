import 'package:auto_route/auto_route.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/player/domain/entities/now_playing_data.dart';
import 'package:music_app/features/song_options/presentation/widgets/song_options_bottom_sheet.dart';
import '../../domain/entities/song.dart';

class SearchResultsWidget extends StatelessWidget {
  final List<Song> results;

  const SearchResultsWidget({required this.results, super.key});

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
    final thumbnail = song.thumbnails.isNotEmpty ? song.thumbnails.last : null;
    final artistsNames = song.artists.map((a) => a.name).join(', ');

    return GestureDetector(
      onTap: () {
        context.router.push(
          PlayerRoute(nowPlayingData: NowPlayingData.fromSong(song)),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        child: Row(
          children: [
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
                          child: const Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(AppColorsDark.primary),
                              ),
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) => Container(
                          width: 60,
                          height: 60,
                          color: AppColorsDark.primaryContainer,
                          child: const Icon(Icons.music_note, color: AppColorsDark.primary),
                        ),
                      )
                    : Container(
                        width: 60,
                        height: 60,
                        color: AppColorsDark.primaryContainer,
                        child: const Icon(Icons.music_note, color: AppColorsDark.primary),
                      ),
              ),
            ),
            const SizedBox(width: 16),
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
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                FavoriteButton(
                  videoId: song.videoId,
                  size: 22,
                  metadata: SongMetadata(
                    title: song.title,
                    artist: artistsNames,
                    thumbnail: thumbnail?.url,
                    duration: song.durationSeconds,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.more_vert,
                    color: Colors.white.withValues(alpha: 0.5),
                  ),
                  onPressed: () {
                    SongOptionsBottomSheet.show(
                      context: context,
                      song: SongOptionsData(
                        videoId: song.videoId,
                        title: song.title,
                        artist: artistsNames,
                        thumbnail: thumbnail?.url,
                        streamUrl: song.streamUrl,
                        durationSeconds: song.durationSeconds,
                        isFavorite: song.inLibrary,
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
