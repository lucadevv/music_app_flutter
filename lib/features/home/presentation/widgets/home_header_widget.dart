import 'package:flutter/material.dart';

/// Widget para el header del home con saludo
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el header con saludo
class HomeHeaderWidget extends StatelessWidget {
  const HomeHeaderWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '👋 Hi',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Good Evening',
            style: TextStyle(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
