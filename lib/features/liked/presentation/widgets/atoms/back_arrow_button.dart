import 'package:flutter/material.dart';

class BackArrowButton extends StatelessWidget {
  final VoidCallback? onTap;

  const BackArrowButton({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
      onPressed: onTap,
    );
  }
}
