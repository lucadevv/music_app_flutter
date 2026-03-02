import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/playlist/presentation/cubit/playlist_state.dart';
import '../cubit/playlist_cubit.dart';

/// Widget para escuchar cambios de estado y efectos
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Escuchar y reaccionar a cambios de estado y efectos
///
/// Nota: Este widget funciona de forma independiente y no requiere
/// OrquestadorHomeCubit. Si está disponible, sincronizará el estado.
class PlaylistListeners extends StatefulWidget {
  final Widget child;

  const PlaylistListeners({required this.child, super.key});

  @override
  State<PlaylistListeners> createState() => _PlaylistListenersState();
}

class _PlaylistListenersState extends State<PlaylistListeners> {
  @override
  Widget build(BuildContext context) {
    return BlocListener<PlaylistCubit, PlaylistState>(
      listener: (context, state) {
        // Manejar errores del PlaylistCubit directamente
        if (state.status == PlaylistStatus.failure &&
            state.errorMessage != null) {
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
