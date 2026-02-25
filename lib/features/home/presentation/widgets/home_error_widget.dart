import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/home_cubit.dart';

/// Widget para mostrar el estado de error del home
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Mostrar el estado de error y permitir reintentar
class HomeErrorWidget extends StatelessWidget {
  final String? errorMessage;

  const HomeErrorWidget({
    super.key,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage ?? 'Error al cargar el home',
            style: const TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<HomeCubit>().loadHome();
            },
            child: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
