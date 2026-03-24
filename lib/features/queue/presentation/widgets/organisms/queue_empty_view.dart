import 'package:flutter/material.dart';
import '../atoms/queue_empty_icon.dart';

/// Organism: Empty queue state view
class QueueEmptyView extends StatelessWidget {
  final String title;
  final String? subtitle;

  const QueueEmptyView({super.key, required this.title, this.subtitle});

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
              color: Colors.white.withValues(alpha: 0.7),
              fontSize: 18,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle!,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 14,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
