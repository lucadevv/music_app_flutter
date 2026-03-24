import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class HeaderIconAtom extends StatelessWidget {
  const HeaderIconAtom({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColorsDark.primary, AppColorsDark.secondary],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.history, size: 60, color: Colors.white),
    );
  }
}
