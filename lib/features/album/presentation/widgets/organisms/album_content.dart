import 'package:flutter/material.dart';
import 'package:music_app/features/album/domain/entities/album.dart';
import 'package:music_app/features/album/presentation/cubit/album_cubit.dart';
import 'package:music_app/features/album/presentation/widgets/molecules/molecules.dart';

/// Organismo: Contenido completo del álbum (actions + songs list)
class AlbumContent extends StatelessWidget {
  final Album album;
  final AlbumState state;
  final void Function(AlbumSong song, List<AlbumSong> allSongs)? onSongTap;
  final VoidCallback? onPlayAllPressed;
  final VoidCallback? onLikePressed;

  const AlbumContent({
    super.key,
    required this.album,
    required this.state,
    this.onSongTap,
    this.onPlayAllPressed,
    this.onLikePressed,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // Songs list
        SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final song = state.songs[index];
            return AlbumSongItem(
              song: song,
              onTap: () => onSongTap?.call(song, state.songs),
            );
          }, childCount: state.songs.length),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}
