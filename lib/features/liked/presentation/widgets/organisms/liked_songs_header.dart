import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/liked/presentation/widgets/atoms/back_arrow_button.dart';
import 'package:music_app/features/liked/presentation/widgets/molecules/header_action_buttons.dart';
import 'package:music_app/features/liked/presentation/widgets/molecules/liked_songs_header_content.dart';

class LikedSongsHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback? onBackTap;
  final VoidCallback? onSearchTap;
  final VoidCallback? onMoreTap;

  const LikedSongsHeader({
    required this.title,
    this.subtitle,
    this.onBackTap,
    this.onSearchTap,
    this.onMoreTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: Colors.transparent,
      leading: BackArrowButton(onTap: onBackTap),
      actions: [
        HeaderActionButtons(onSearchTap: onSearchTap, onMoreTap: onMoreTap),
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
          child: LikedSongsHeaderContent(title: title, subtitle: subtitle),
        ),
      ),
    );
  }
}
