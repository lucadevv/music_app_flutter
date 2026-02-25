import 'package:flutter/material.dart';

extension BuildContextX on BuildContext {
  Size get size => MediaQuery.sizeOf(this);
  ThemeData get theme => Theme.of(this);
  ColorScheme get appColor => theme.colorScheme;
  ThemeData get _theme => Theme.of(this);
  TextTheme get appTextTheme => _theme.textTheme;
  double get screenWidth => size.width;
  double get screenHeight => size.height;
  double get viewInsetsBottom => MediaQuery.viewInsetsOf(this).bottom;
}
