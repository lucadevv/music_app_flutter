import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

import '../atoms/queue_empty_icon.dart';

/// Organism: Empty queue state view
class QueueEmptyView extends StatelessWidget {
  final String title;
  final String? subtitle;

  const QueueEmptyView({required this.title, super.key, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const QueueEmptyIcon(),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              color: AppColorsDark.onSurface.withValues(alpha: 0.7),
              fontSize: 18,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: AppColorsDark.onSurface.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
