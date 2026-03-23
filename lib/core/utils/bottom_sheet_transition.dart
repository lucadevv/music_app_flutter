import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:music_app/core/utils/bottom_sheet_visibility.dart';

/// Helper para transiciones seguras entre bottom sheets
///
/// Asegura que el bottom sheet anterior se cierre completamente antes de
/// mostrar el siguiente, evitando problemas de timing y context
class BottomSheetTransition {
  /// Muestra un bottom sheet después de cerrar el actual de forma segura
  ///
  /// Usage:
  /// ```dart
  /// await BottomSheetTransition.showNext(
  ///   context: context,
  ///   builder: (context) => MiNuevoBottomSheet(),
  /// );
  /// ```
  static Future<T?> showNext<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    Duration delay = const Duration(milliseconds: 100),
  }) async {
    if (!context.mounted) return null;

    try {
      Navigator.of(context).pop();
      await Future.delayed(delay);

      if (!context.mounted) return null;

      return await BottomSheetVisibility().showBottomSheet<T>(
        context: context,
        builder: builder,
      );
    } catch (e, stackTrace) {
      debugPrint('Error in bottom sheet transition: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (kDebugMode && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return null;
    }
  }

  /// Versión sin await que maneja el cierre y apertura de forma asíncrona
  static void showNextAsync({
    required BuildContext context,
    required WidgetBuilder builder,
    Duration delay = const Duration(milliseconds: 100),
  }) {
    if (!context.mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        Navigator.of(context).pop();
        await Future.delayed(delay);

        if (!context.mounted) return;

        unawaited(
          BottomSheetVisibility().showBottomSheet(
            context: context,
            builder: builder,
          ),
        );
      } catch (e) {
        debugPrint('Error in bottom sheet async transition: $e');
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al abrir opciones'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    });
  }
}
