import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';

import '../cubit/login_cubit.dart' show LoginStatus, LoginCubit, LoginState;

/// Widget que escucha los cambios del LoginCubit y OrquestadorAuthCubit
/// Maneja las navegaciones y errores
class LoginListeners extends StatelessWidget {
  final Widget child;

  const LoginListeners({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener para actualizar el estado del login en el orquestador
        BlocListener<LoginCubit, LoginState>(
          listener: (context, state) {
            final orquestador = context.read<OrquestadorAuthCubit>();
            orquestador.updateLoginState(state);

            if (state.status == LoginStatus.success &&
                state.responseEntity != null) {
              orquestador.handleLoginSuccess(state.responseEntity!);
            } else if (state.status == LoginStatus.failure) {
              orquestador.handleError(
                state.errorMessage ?? 'Error al iniciar sesión',
              );
            }
          },
        ),
        // Listener para efectos de navegación del orquestador
        BlocListener<OrquestadorAuthCubit, OrquestadorAuthState>(
          listener: (context, state) {
            final effect = state.effect;
            if (effect == null) return;

            if (effect is NavigateToDashboardEffect) {
              context.read<OrquestadorAuthCubit>().clearEffect();
              if (!context.mounted) return;
              context.router.replaceAll([const DashboardShell()]);
            } else if (effect is NavigateToEmailVerificationEffect) {
              context.read<OrquestadorAuthCubit>().clearEffect();
              if (!context.mounted) return;
              context.router.replaceAll([
                const DashboardShell(children: [EmailVerificationRoute()]),
              ]);
            } else if (effect is ShowErrorEffect) {
              context.read<OrquestadorAuthCubit>().clearEffect();
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
      child: child,
    );
  }
}
