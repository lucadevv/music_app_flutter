import 'package:flutter/material.dart';

/// Widget para mostrar errores en el reproductor
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar mensajes de error
class PlayerErrorWidget extends StatelessWidget {
  final String message;

  const PlayerErrorWidget({
    required this.message, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
