import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/relax/presentation/atoms/app_text_styles.dart';

class MusicCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final double width;

  const MusicCard({
    required this.title,
    required this.subtitle,
    required this.width,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColorsDark.primaryContainer,
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              ),
              child: const Center(
                child: Icon(
                  Icons.music_note,
                  size: 60,
                  color: AppColorsDark.primary,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: RelaxTextStyles.cardTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(subtitle, style: RelaxTextStyles.cardSubtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
