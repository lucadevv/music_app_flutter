import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';
import 'package:music_app/features/auth/login/presentation/cubit/login_cubit.dart';
import 'package:music_app/l10n/app_localizations.dart';

class SocialAuthButtons extends StatelessWidget {
  final bool isVertical;

  const SocialAuthButtons({
    super.key,
    this.isVertical = false,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (isVertical) {
      return Column(
        children: [
          BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              final isThisLoading = state.isLoadingFor(OAuthProviderType.google);
              final isAnyLoading = state.status == LoginStatus.loading;
              return _SocialButtonVertical(
                icon: Icons.g_mobiledata,
                label: l10n.continueWithGoogle,
                isLoading: isThisLoading,
                onPressed: isAnyLoading
                    ? null
                    : () {
                        context.read<LoginCubit>().signInWithGoogle();
                      },
              );
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              final isThisLoading = state.isLoadingFor(OAuthProviderType.apple);
              final isAnyLoading = state.status == LoginStatus.loading;
              return _SocialButtonVertical(
                icon: Icons.apple,
                label: l10n.continueWithApple,
                isLoading: isThisLoading,
                onPressed: isAnyLoading
                    ? null
                    : () {
                        context.read<LoginCubit>().signInWithApple();
                      },
              );
            },
          ),
        ],
      );
    }

    return Row(
      children: [
        Expanded(
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              final isThisLoading = state.isLoadingFor(OAuthProviderType.google);
              final isAnyLoading = state.status == LoginStatus.loading;
              return _SocialButtonHorizontal(
                icon: Icons.g_mobiledata,
                label: l10n.google,
                iconSize: 28,
                isLoading: isThisLoading,
                onPressed: isAnyLoading
                    ? null
                    : () {
                        context.read<LoginCubit>().signInWithGoogle();
                      },
              );
            },
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BlocBuilder<LoginCubit, LoginState>(
            builder: (context, state) {
              final isThisLoading = state.isLoadingFor(OAuthProviderType.apple);
              final isAnyLoading = state.status == LoginStatus.loading;
              return _SocialButtonHorizontal(
                icon: Icons.apple,
                label: l10n.apple,
                iconSize: 24,
                isLoading: isThisLoading,
                onPressed: isAnyLoading
                    ? null
                    : () {
                        context.read<LoginCubit>().signInWithApple();
                      },
              );
            },
          ),
        ),
      ],
    );
  }
}

class _SocialButtonVertical extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialButtonVertical({
    required this.icon,
    required this.label,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: AppColorsDark.surfaceContainerHigh,
        foregroundColor: AppColorsDark.onSurface,
        padding: const EdgeInsets.symmetric(vertical: 16),
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),
      child: isLoading
          ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppColorsDark.onSurface,
                ),
              ),
            )
          : Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 24),
                const SizedBox(width: 12),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SocialButtonHorizontal extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialButtonHorizontal({
    required this.icon,
    required this.label,
    required this.iconSize,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ],
        ),
      ),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Icon(
                icon,
                color: Colors.white,
                size: iconSize,
              ),
        label: Text(
          label,
          style: const TextStyle(color: Colors.white),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: BorderSide(
            color: Colors.white.withValues(alpha: 0.3),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}
