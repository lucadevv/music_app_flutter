import 'package:flutter/material.dart';
import '../atoms/atoms.dart';

class ActionButtonsMolecule extends StatelessWidget {
  final bool showSendButton;
  final String sendButtonLabel;
  final String linkButtonLabel;
  final VoidCallback? onSendPressed;
  final VoidCallback? onLinkPressed;

  const ActionButtonsMolecule({
    required this.showSendButton,
    required this.sendButtonLabel,
    required this.linkButtonLabel,
    super.key,
    this.onSendPressed,
    this.onLinkPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showSendButton)
          PrimaryButton(label: sendButtonLabel, onPressed: onSendPressed)
        else
          PrimaryButton(label: sendButtonLabel, onPressed: onLinkPressed),
        const SizedBox(height: 24),
        if (showSendButton)
          LinkButton(label: linkButtonLabel, onPressed: onLinkPressed),
      ],
    );
  }
}
