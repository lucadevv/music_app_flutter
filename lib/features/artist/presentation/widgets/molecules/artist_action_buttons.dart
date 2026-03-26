import 'package:flutter/material.dart';
import 'package:music_app/core/domain/entities/artist.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/artist/presentation/cubit/artist_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

class ArtistActionButtons extends StatelessWidget {
  final Artist artist;
  final ArtistState state;
  final VoidCallback onPlayPressed;
  final VoidCallback onFollowPressed;

  const ArtistActionButtons({
    required this.artist,
    required this.state,
    required this.onPlayPressed,
    required this.onFollowPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: onPlayPressed,
            icon: const Icon(Icons.play_arrow),
            label: Text(l10n.play),
            style: FilledButton.styleFrom(
              backgroundColor: AppColorsDark.primary,
              foregroundColor: AppColorsDark.onSurface,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ),
        const SizedBox(width: 16),
        IconButton(
          icon: Icon(
            state.isFollowing ? Icons.favorite : Icons.favorite_border,
            color: state.isFollowing
                ? AppColorsDark.primary
                : AppColorsDark.onSurface,
          ),
          onPressed: onFollowPressed,
        ),
        IconButton(
          icon: const Icon(Icons.share, color: AppColorsDark.onSurface),
          onPressed: () {},
        ),
      ],
    );
  }
}
