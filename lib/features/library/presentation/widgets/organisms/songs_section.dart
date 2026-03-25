import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/library/data/models/library_models.dart';
import 'package:music_app/features/library/presentation/cubit/library_cubit.dart';
import 'package:music_app/features/library/presentation/widgets/organisms/song_list_item_widget.dart';
import 'package:music_app/l10n/app_localizations.dart';

/// Sección de canciones en la biblioteca.
class SongsSection extends StatelessWidget {
  final List<FavoriteSong> songs;
  final bool showViewAll;
  final void Function(FavoriteSong song, AppLocalizations l10n) onShowOptions;
  final bool usePlayAllFromIndex;

  const SongsSection({
    required this.songs,
    required this.onShowOptions,
    this.showViewAll = true,
    this.usePlayAllFromIndex = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                l10n.likedSongs,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
              if (showViewAll && songs.length > 5)
                Icon(
                  Icons.chevron_right,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            return SongListItemWidget(
              song: song,
              onTap: () => _onSongTap(context, song, index),
              onOptionsTap: () => onShowOptions(song, l10n),
            );
          },
        ),
      ],
    );
  }

  void _onSongTap(BuildContext context, FavoriteSong song, int index) {
    final cubit = context.read<LibraryCubit>();

    final nowPlayingData = usePlayAllFromIndex
        ? cubit.playAllFavoriteSongsFromIndex(songs, index)
        : cubit.playSong(song);

    if (nowPlayingData != null) {
      context.router.push(
        PlayerRoute(
          nowPlayingData: nowPlayingData,
          playAsSingle: !usePlayAllFromIndex,
        ),
      );
    }
  }
}
