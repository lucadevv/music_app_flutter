import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/home/presentation/cubit/orquestador_home_cubit.dart';
import '../cubit/mood_genre_cubit.dart';

/// Widget para escuchar cambios de estado y efectos
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Escuchar y reaccionar a cambios de estado y efectos
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
  void initState() {
    super.initState();
    // El cubit ya se registra en el orquestador en wrappedRoute
    // Aquí solo sincronizamos el estado inicial si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final moodGenreCubit = context.read<MoodGenreCubit>();
        final orquestadorCubit = context.read<OrquestadorHomeCubit>();
        // El orquestador ya escucha el stream, solo actualizamos el estado manualmente
        orquestadorCubit.updateMoodGenreState(moodGenreCubit.state);
      } catch (e) {
        // Orquestador no disponible en este contexto
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Escuchar cambios del MoodGenreCubit y actualizar el orquestador
        BlocListener<MoodGenreCubit, MoodGenreState>(
          listener: (context, state) {
            context.read<OrquestadorHomeCubit>().updateMoodGenreState(state);
          },
        ),
        // Escuchar efectos del orquestador
        BlocListener<OrquestadorHomeCubit, OrquestadorHomeState>(
          listenWhen: (previous, current) => current.effect != null,
          listener: (context, state) {
            final effect = state.effect;
            if (effect == null || !mounted) return;

            if (effect is ShowErrorEffect) {
              context.read<OrquestadorHomeCubit>().clearEffect();
              if (!mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(effect.message),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
        ),
      ],
      child: widget.child,
    );
  }
}
