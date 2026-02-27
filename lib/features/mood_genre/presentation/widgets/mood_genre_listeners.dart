import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../cubit/mood_genre_cubit.dart';

/// Widget para escuchar cambios de estado y efectos
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Escuchar y reaccionar a cambios de estado y efectos
/// 
/// Nota: Este widget funciona de forma independiente y no requiere
/// OrquestadorHomeCubit. Si está disponible, sincronizará el estado.
class MoodGenreListeners extends StatefulWidget {
  final Widget child;

  const MoodGenreListeners({
    super.key,
    required this.child,
  });

  @override
  State<MoodGenreListeners> createState() => _MoodGenreListenersState();
}

class _MoodGenreListenersState extends State<MoodGenreListeners> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<MoodGenreCubit, MoodGenreState>(
      listener: (context, state) {
        // Manejar errores del MoodGenreCubit directamente
        if (state.status == MoodGenreStatus.failure && state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: widget.child,
    );
  }
}
