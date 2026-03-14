import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart';
import 'package:music_app/features/home/presentation/cubit/orquestador_home_cubit.dart';

/// Widget para escuchar cambios de estado y efectos del home
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Manejar efectos y actualizar el orquestador
class HomeListeners extends StatefulWidget {
  final Widget child;

  const HomeListeners({required this.child, super.key});

  @override
  State<HomeListeners> createState() => _HomeListenersState();
}

class _HomeListenersState extends State<HomeListeners> {
  @override
  void initState() {
    super.initState();
    // Sincronizar el estado inicial del orquestador con el HomeCubit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final homeCubit = context.read<HomeCubit>();
      final orquestadorCubit = context.read<OrquestadorHomeCubit>();
      orquestadorCubit.updateHomeState(homeCubit.state);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener para actualizar el orquestador cuando cambia el estado del home
        BlocListener<HomeCubit, HomeState>(
          listener: (context, state) {
            context.read<OrquestadorHomeCubit>().updateHomeState(state);
          },
        ),

        // Listener para efectos del orquestador
        BlocListener<OrquestadorHomeCubit, OrquestadorHomeState>(
          listenWhen: (previous, current) => previous.effect != current.effect,
          listener: (context, state) {
            final effect = state.effect;
            if (effect == null) return;

            if (effect is ShowErrorEffect) {
              context.read<OrquestadorHomeCubit>().clearEffect();
              if (!context.mounted) return;

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
