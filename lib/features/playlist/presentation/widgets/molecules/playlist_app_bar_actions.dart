import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class PlaylistAppBarActions extends StatelessWidget {
  final bool showSearch;
  final VoidCallback onSearchPressed;
  final VoidCallback onMorePressed;

  const PlaylistAppBarActions({
    required this.showSearch,
    required this.onSearchPressed,
    required this.onMorePressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _ActionButton(
          icon: showSearch ? Icons.close : Icons.search,
          onPressed: onSearchPressed,
        ),
        _ActionButton(icon: Icons.more_vert, onPressed: onMorePressed),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColorsDark.surfaceDim.withValues(alpha: 0.3),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(icon, color: AppColorsDark.onSurface, size: 20),
        onPressed: onPressed,
      ),
    );
  }
}
