import 'package:flutter/material.dart';

class DialogUtils {
  static Future<T?> showCustomDialog<T>({
    required BuildContext context,
    required Widget content,
    List<Widget>? actions,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    EdgeInsets insetPadding = const EdgeInsets.all(20),
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
    String? title,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        insetPadding: insetPadding,
        title: title != null ? Text(title) : null,
        content: content,
        actions: actions, // ✅ Actions personalizables
      ),
    );
  }

  // ✅ Dialog con botones predefinidos (Aceptar/Cancelar)
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required Widget content,
    String title = "Confirmar",
    String acceptText = "Aceptar",
    String cancelText = "Cancelar",
    Color? acceptColor,
    Color? cancelColor,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    EdgeInsets insetPadding = const EdgeInsets.all(20),
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        insetPadding: insetPadding,
        title: Text(title),
        content: content,
        actions: [
          // ✅ Cancelar - retorna false
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              cancelText,
              style: TextStyle(color: cancelColor ?? Colors.grey),
            ),
          ),
          // ✅ Aceptar - retorna true
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              acceptText,
              style: TextStyle(color: acceptColor ?? Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Dialog de información simple
  static Future<void> showInfoDialog({
    required BuildContext context,
    required Widget content,
    String title = "Información",
    String buttonText = "Aceptar",
    Color? buttonColor,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    EdgeInsets insetPadding = const EdgeInsets.all(20),
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        insetPadding: insetPadding,
        title: Text(title),
        content: content,
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              buttonText,
              style: TextStyle(color: buttonColor ?? Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Dialog con actions personalizadas que retornan valores
  static Future<T?> showActionDialog<T>({
    required BuildContext context,
    required Widget content,
    required Map<String, T> actions, // ✅ Map de acciones con valores de retorno
    String? title,
    bool barrierDismissible = true,
    bool useRootNavigator = true,
    EdgeInsets insetPadding = const EdgeInsets.all(20),
    Color? backgroundColor,
    double? elevation,
    ShapeBorder? shape,
  }) {
    return showDialog<T>(
      context: context,
      barrierDismissible: barrierDismissible,
      useRootNavigator: useRootNavigator,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        elevation: elevation,
        shape: shape,
        insetPadding: insetPadding,
        title: title != null ? Text(title) : null,
        content: content,
        actions: [
          // ✅ Generar botones dinámicamente desde el map
          for (final entry in actions.entries)
            TextButton(
              onPressed: () => Navigator.of(context).pop(entry.value),
              child: Text(entry.key),
            ),
        ],
      ),
    );
  }

  static void closeDialog(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}
