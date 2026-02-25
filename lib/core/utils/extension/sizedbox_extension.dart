import 'package:flutter/material.dart';

extension SizedboxExtension on num {
  SizedBox get spaceh => SizedBox(height: toDouble());
  SizedBox get spacew => SizedBox(width: toDouble());
}
