import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/recently_played/presentation/widgets/atoms/back_button_atom.dart';
import 'package:music_app/features/recently_played/presentation/widgets/atoms/header_action_buttons_atom.dart';
import 'package:music_app/features/recently_played/presentation/widgets/molecules/header_content_molecule.dart';

class RecentlyPlayedHeaderOrganism extends StatelessWidget {
  final int songCount;

  const RecentlyPlayedHeaderOrganism({super.key, required this.songCount});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: BackButtonAtom(onPressed: () => context.router.maybePop()),
      actions: const [
        SearchButtonAtom(onPressed: _onSearchTap),
        MoreButtonAtom(onPressed: _onMoreTap),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [AppColorsDark.primaryContainer, Color(0xFF0D0D0D)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: HeaderContentMolecule(songCount: songCount),
            ),
          ),
        ),
      ),
    );
  }

  static void _onSearchTap() {
    // TODO: Implement search functionality
  }

  static void _onMoreTap() {
    // TODO: Implement more options
  }
}
