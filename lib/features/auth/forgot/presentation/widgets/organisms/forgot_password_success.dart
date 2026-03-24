import 'package:flutter/material.dart';
import '../atoms/atoms.dart';
import '../molecules/molecules.dart';

class ForgotPasswordSuccess extends StatelessWidget {
  final String buttonLabel;
  final String linkLabel;
  final VoidCallback onButtonPressed;
  final VoidCallback onLinkPressed;

  const ForgotPasswordSuccess({
    super.key,
    required this.buttonLabel,
    required this.linkLabel,
    required this.onButtonPressed,
    required this.onLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ActionButtonsMolecule(
          showSendButton: false,
          sendButtonLabel: buttonLabel,
          linkButtonLabel: linkLabel,
          onLinkPressed: onButtonPressed,
        ),
        const SizedBox(height: 24),
        LinkButton(label: linkLabel, onPressed: onLinkPressed),
      ],
    );
  }
}
