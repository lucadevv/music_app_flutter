import 'package:flutter/material.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/presentation/widgets/song_list_item.dart';
import 'package:music_app/features/library/library_service.dart';

/// Widget para mostrar una canción en formato lista.
/// Acepta FavoriteSong que es el tipo usado en library.
class SongListItemWidget extends StatelessWidget {
  final FavoriteSong song;
  final VoidCallback onTap;
  final VoidCallback? onOptionsTap;

  const SongListItemWidget({
    required this.song,
    required this.onTap,
    this.onOptionsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SongListItemFromEntity(
      song: _toSong(song),
      trailing: onOptionsTap != null
          ? IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: onOptionsTap,
            )
          : null,
      onTap: onTap,
    );
  }

  /// Convierte FavoriteSong a Song para usar con SongListItemFromEntity
  Song _toSong(FavoriteSong fav) {
    return Song(
      videoId: fav.videoId,
      title: fav.title,
      artist: fav.artist,
      thumbnail: fav.thumbnail,
      durationSeconds: fav.duration ?? 0,
      streamUrl: fav.streamUrl,
    );
  }
}
