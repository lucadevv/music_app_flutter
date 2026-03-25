import 'package:flutter/material.dart';
import '../molecules/molecules.dart';

class ForgotPasswordForm extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final String emailLabel;
  final String sendButtonLabel;
  final VoidCallback onSendPressed;

  const ForgotPasswordForm({
    required this.formKey, required this.emailController, required this.emailLabel, required this.sendButtonLabel, required this.onSendPressed, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          EmailInputMolecule(
            controller: emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return emailLabel;
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
            linkButtonLabel: 'Back to Login',
            onSendPressed: onSendPressed,
          ),
        ],
      ),
    );
  }
}
