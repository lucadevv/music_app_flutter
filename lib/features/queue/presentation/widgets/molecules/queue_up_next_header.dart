import 'package:flutter/material.dart';
import '../atoms/queue_up_next_label.dart';

/// Molecule: Header row for "Up Next" section
class QueueUpNextHeader extends StatelessWidget {
  final String upNextLabel;
  final String autoRecommendationsLabel;
  final VoidCallback? onAutoRecommendationsTap;

  const QueueUpNextHeader({
    required this.upNextLabel, required this.autoRecommendationsLabel, super.key,
    this.onAutoRecommendationsTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          QueueUpNextLabel(text: upNextLabel),
          const Spacer(),
          TextButton(
            onPressed: onAutoRecommendationsTap,
            child: Text(
              autoRecommendationsLabel,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}
