import 'dart:ui';

import 'package:flutter/material.dart';

class GlassBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<IconData> outlinedIcons;
  final List<IconData> filledIcons;

  const GlassBottomNav({
    required this.currentIndex, required this.onTap, required this.outlinedIcons, required this.filledIcons, super.key,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              color: colorScheme.surface.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: colorScheme.outline.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(outlinedIcons.length, (index) {
                return _buildNavItem(outlinedIcons[index], filledIcons[index], index, colorScheme);
              }),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData iconOutlined, IconData iconFilled, int index, ColorScheme colorScheme) {
    final isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onTap(index),
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.onSurface.withValues(alpha: 0.15) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Icon(
          isSelected ? iconFilled : iconOutlined,
          color: isSelected ? colorScheme.onSurface : colorScheme.onSurfaceVariant,
          size: 28,
        ),
      ),
    );
  }
}
