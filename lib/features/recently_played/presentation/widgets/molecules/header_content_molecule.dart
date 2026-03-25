import 'package:flutter/material.dart';
import 'package:music_app/features/recently_played/presentation/widgets/atoms/header_icon_atom.dart';
import 'package:music_app/l10n/app_localizations.dart';

class HeaderContentMolecule extends StatelessWidget {
  final int songCount;

  const HeaderContentMolecule({required this.songCount, super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const HeaderIconAtom(),
        const SizedBox(height: 12),
        Text(
          l10n.recentlyPlayed,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$songCount ${l10n.songs}',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
