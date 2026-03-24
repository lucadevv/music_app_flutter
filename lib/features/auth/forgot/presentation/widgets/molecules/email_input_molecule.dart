import 'package:flutter/material.dart';
import '../atoms/atoms.dart';

class EmailInputMolecule extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const EmailInputMolecule({
    super.key,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        EmailTextField(controller: controller, validator: validator),
        const SizedBox(height: 32),
      ],
    );
  }
}
