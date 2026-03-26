import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class PlaylistSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const PlaylistSearchBar({
    required this.controller,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: const TextStyle(color: AppColorsDark.onSurface),
        decoration: InputDecoration(
          hintText: 'Search songs...',
          hintStyle: TextStyle(
            color: AppColorsDark.onSurface.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColorsDark.onSurface.withValues(alpha: 0.5),
          ),
          filled: true,
          fillColor: AppColorsDark.onSurface.withValues(alpha: 0.1),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }
}
