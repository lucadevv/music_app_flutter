import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/home/presentation/cubit/orquestador_home_cubit.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_state.dart';
import '../cubit/playlist_cubit.dart';

/// Widget para escuchar cambios de estado y efectos
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Escuchar y reaccionar a cambios de estado y efectos
class PlaylistListeners extends StatefulWidget {
  final Widget child;

  const PlaylistListeners({super.key, required this.child});

  @override
  State<PlaylistListeners> createState() => _PlaylistListenersState();
}

class _PlaylistListenersState extends State<PlaylistListeners> {
  @override
  void initState() {
    super.initState();
    // El cubit ya se registra en el orquestador en wrappedRoute
    // Aquí solo sincronizamos el estado inicial si es necesario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      try {
        final playlistCubit = context.read<PlaylistCubit>();
        final orquestadorCubit = context.read<OrquestadorHomeCubit>();
        // El orquestador ya escucha el stream, solo actualizamos el estado manualmente
        orquestadorCubit.updatePlaylistState(playlistCubit.state);
      } catch (e) {
        // Orquestador no disponible en este contexto
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Escuchar cambios del PlaylistCubit y actualizar el orquestador
        BlocListener<PlaylistCubit, PlaylistState>(
          listener: (context, state) {
            context.read<OrquestadorHomeCubit>().updatePlaylistState(state);
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
