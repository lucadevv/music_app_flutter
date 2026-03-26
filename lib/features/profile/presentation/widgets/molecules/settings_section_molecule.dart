import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class SettingsSectionMolecule extends StatelessWidget {
  final String title;
  final List<Widget> items;

  const SettingsSectionMolecule({
    required this.title,
    required this.items,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
          child: Text(
            title,
            style: TextStyle(
              color: AppColorsDark.onSurface.withValues(alpha: 0.6),
              fontSize: 12,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
        ),
        ...items,
      ],
    );
  }
}
