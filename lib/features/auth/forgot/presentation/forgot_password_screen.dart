import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

@RoutePage()
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _sendResetEmail() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementar envío de email de recuperación
      setState(() {
        _emailSent = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsDark.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorsDark.onSurface),
          onPressed: () => context.router.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColorsDark.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.lock_reset,
                    size: 50,
                    color: AppColorsDark.primary,
                  ),
                ),
                const SizedBox(height: 32),

                // Título
                Text(
                  _emailSent ? 'Email enviado' : 'Recuperar contraseña',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: AppColorsDark.onSurface,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  _emailSent
                      ? 'Revisa tu bandeja de entrada para restablecer tu contraseña'
                      : 'Ingresa tu email y te enviaremos las instrucciones para restablecer tu contraseña',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColorsDark.onSurfaceVariant,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                if (!_emailSent) ...[
                  // Email field
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'tu@email.com',
                      prefixIcon: Icon(Icons.email, color: AppColorsDark.primary),
                      filled: true,
                      fillColor: AppColorsDark.surfaceContainerHigh,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      labelStyle: TextStyle(color: AppColorsDark.onSurfaceVariant),
                      hintStyle: TextStyle(color: AppColorsDark.onSurfaceVariant),
                    ),
                    style: TextStyle(color: AppColorsDark.onSurface),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingresa tu email';
                      }
                      if (!value.contains('@')) {
                        return 'Ingresa un email válido';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // Send button
                  FilledButton(
                    onPressed: _sendResetEmail,
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColorsDark.primary,
                      foregroundColor: AppColorsDark.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Enviar instrucciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ] else ...[
                  // Success icon
                  Icon(
                    Icons.check_circle,
                    size: 80,
                    color: AppColorsDark.primary,
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed: () {
                      context.router.push(const LoginRoute());
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColorsDark.primary,
                      foregroundColor: AppColorsDark.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Volver a iniciar sesión',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),

                // Back to login link
                TextButton(
                  onPressed: () {
                    context.router.push(const LoginRoute());
                  },
                  child: Text(
                    'Volver a iniciar sesión',
                    style: TextStyle(
                      color: AppColorsDark.primary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
