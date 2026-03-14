import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/favorites/presentation/widgets/favorite_button.dart';
import 'package:music_app/features/library/library_service.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';

class SongListItemWidget extends StatelessWidget {
  final FavoriteSong song;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const SongListItemWidget({
    required this.song,
    required this.onTap,
    required this.onOptionsTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: 52,
          height: 52,
          color: AppColorsDark.primaryContainer,
          child: song.thumbnail != null
              ? CachedNetworkImage(
                  imageUrl: song.thumbnail!,
                  fit: BoxFit.cover,
                  errorWidget: (_, _, _) => const Icon(
                    Icons.music_note,
                    color: AppColorsDark.primary,
                  ),
                )
              : const Icon(Icons.music_note, color: AppColorsDark.primary),
        ),
      ),
      title: Text(
        song.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w500,
          fontFamily: 'Poppins',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artist,
        style: TextStyle(
          color: Colors.white.withValues(alpha: 0.6),
          fontSize: 13,
          fontFamily: 'Poppins',
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          FavoriteButton(
            videoId: song.videoId,
            songId: song.songId,
            size: 22,
            metadata: SongMetadata(
              title: song.title,
              artist: song.artist,
              thumbnail: song.thumbnail,
              duration: song.duration,
            ),
            onToggle: () => context.read<LibraryCubit>().loadLibrary(),
          ),
          IconButton(
            icon: Icon(
              Icons.more_vert,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            onPressed: onOptionsTap,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}
