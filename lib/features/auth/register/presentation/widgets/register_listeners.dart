import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:auto_route/auto_route.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/auth/presentation/cubit/orquestador_auth_cubit.dart';
import 'package:music_app/features/auth/register/presentation/cubit/register_cubit.dart'
    show RegisterCubit, RegisterState, RegisterStatus;

class RegisterListeners extends StatelessWidget {
  final Widget child;

  const RegisterListeners({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // Listener para sincronizar estado del RegisterCubit con Orquestador
        BlocListener<RegisterCubit, RegisterState>(
          listener: (context, state) {
            final orquestador = context.read<OrquestadorAuthCubit>();
            orquestador.updateRegisterState(state);

            if (state.status == RegisterStatus.success &&
                state.responseEntity != null) {
              orquestador.handleRegisterSuccess(state.responseEntity!);
            } else if (state.status == RegisterStatus.failure) {
              orquestador.handleError(
                state.errorMessage ?? 'Error al registrar',
              );
            }
          },
        ),
        // Listener para efectos de navegación del orquestador
        // El cubit ya guardó los tokens, solo navegamos según el efecto
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
            }
          },
        ),
        // Listener para errores
        BlocListener<OrquestadorAuthCubit, OrquestadorAuthState>(
          listenWhen: (previous, current) =>
              previous.registerState.status != current.registerState.status,
          listener: (context, state) {
            if (state.registerState.status == RegisterStatus.failure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    state.registerState.errorMessage ?? 'Error al registrar',
                  ),
                  backgroundColor: AppColorsDark.error,
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
