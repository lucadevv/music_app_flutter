import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

class ForgotPasswordContent extends StatelessWidget {
  final bool emailSent;
  final String title;
  final String description;
  final String sendButtonLabel;
  final String backToLoginLabel;
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final VoidCallback onSendPressed;

  const ForgotPasswordContent({
    super.key,
    required this.emailSent,
    required this.title,
    required this.description,
    required this.sendButtonLabel,
    required this.backToLoginLabel,
    required this.formKey,
    required this.emailController,
    required this.onSendPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ForgotPasswordHeader(
              emailSent: emailSent,
              title: title,
              description: description,
            ),
            const SizedBox(height: 32),
            if (!emailSent) ...[
              EmailInputMolecule(
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!value.contains('@')) {
                    return 'Please enter a valid email';
                  }
                  return null;
                },
              ),
              ActionButtonsMolecule(
                showSendButton: true,
                sendButtonLabel: sendButtonLabel,
                linkButtonLabel: backToLoginLabel,
                onSendPressed: onSendPressed,
                onLinkPressed: () => context.router.push(const LoginRoute()),
              ),
            ] else ...[
              const SuccessIcon(),
              const SizedBox(height: 24),
              ActionButtonsMolecule(
                showSendButton: false,
                sendButtonLabel: backToLoginLabel,
                linkButtonLabel: backToLoginLabel,
                onLinkPressed: () => context.router.push(const LoginRoute()),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
