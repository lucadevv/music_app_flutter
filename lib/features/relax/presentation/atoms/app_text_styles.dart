import 'package:flutter/material.dart';

class RelaxTextStyles {
  RelaxTextStyles._();

  static TextStyle get greeting =>
      TextStyle(color: Colors.white.withValues(alpha: 0.75), fontSize: 16);

  static TextStyle get title => const TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get sectionTitle => const TextStyle(
    color: Colors.white,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static TextStyle get cardTitle => const TextStyle(
    color: Colors.white,
    fontSize: 14,
    fontWeight: FontWeight.w600,
  );

  static TextStyle get cardSubtitle =>
      TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 12);

  static TextStyle chip({required bool isSelected}) => TextStyle(
    color: isSelected ? Colors.black : Colors.white,
    fontSize: 14,
    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
  );
}
