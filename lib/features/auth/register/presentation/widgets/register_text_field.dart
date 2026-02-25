import 'package:flutter/material.dart';
import 'package:music_app/core/theme/app_colors_dark.dart';

class RegisterTextField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final IconData prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final String? errorText;
  final TextInputType? keyboardType;
  final VoidCallback? onSuffixIconPressed;
  final ValueChanged<String>? onChanged;

  const RegisterTextField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.errorText,
    this.keyboardType,
    this.onSuffixIconPressed,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: labelText,
        hintText: hintText,
        prefixIcon: Icon(prefixIcon, color: AppColorsDark.primary),
        suffixIcon: suffixIcon != null && onSuffixIconPressed != null
            ? IconButton(
                icon: Icon(
                  suffixIcon,
                  color: AppColorsDark.onSurfaceVariant,
                ),
                onPressed: onSuffixIconPressed,
              )
            : null,
        filled: true,
        fillColor: AppColorsDark.surfaceContainerHigh,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(20),
          borderSide: BorderSide.none,
        ),
        errorText: errorText,
        labelStyle: TextStyle(color: AppColorsDark.onSurfaceVariant),
        hintStyle: TextStyle(color: AppColorsDark.onSurfaceVariant),
      ),
      style: TextStyle(color: AppColorsDark.onSurface),
      onChanged: onChanged,
    );
  }
}
