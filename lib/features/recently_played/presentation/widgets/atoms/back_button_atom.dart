import 'package:flutter/material.dart';

class BackButtonAtom extends StatelessWidget {
  final VoidCallback onPressed;

  const BackButtonAtom({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      onPressed: onPressed,
    );
  }
}
