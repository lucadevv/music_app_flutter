import 'package:flutter/material.dart';
import '../atoms/atoms.dart';

class ForgotPasswordHeader extends StatelessWidget {
  final bool emailSent;
  final String title;
  final String description;

  const ForgotPasswordHeader({
    required this.emailSent, required this.title, required this.description, super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Icon
        if (emailSent) const SuccessIcon() else const ForgotPasswordIcon(),
        const SizedBox(height: 32),

        // Title
        ForgotPasswordTitle(title: title),
        const SizedBox(height: 8),

        // Description
        ForgotPasswordDescription(description: description),
      ],
    );
  }
}
