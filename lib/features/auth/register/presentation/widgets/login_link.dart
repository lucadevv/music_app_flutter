import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () {
        context.router.push(const LoginRoute());
      },
      child: RichText(
        text: TextSpan(
          style: TextStyle(
            color: AppColorsDark.onSurfaceVariant,
            fontSize: 14,
          ),
          children: [
            const TextSpan(text: '¿Ya tienes una cuenta? '),
            TextSpan(
              text: 'Iniciar sesión',
              style: TextStyle(
                color: AppColorsDark.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
