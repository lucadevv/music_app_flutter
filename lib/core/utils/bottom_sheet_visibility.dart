import 'package:flutter/material.dart';

/// Provider global para controlar el estado del bottom sheet
/// Esto permite que el miniplayer se mueva cuando se abre un bottom sheet
class BottomSheetVisibility extends ChangeNotifier {
  static final BottomSheetVisibility _instance = BottomSheetVisibility._internal();
  factory BottomSheetVisibility() => _instance;
  BottomSheetVisibility._internal();

  bool _isBottomSheetOpen = false;
  double _extraPadding = 0;

  bool get isBottomSheetOpen => _isBottomSheetOpen;
  double get extraPadding => _extraPadding;

  /// Called when a bottom sheet is opened
  void onBottomSheetOpened() {
    _isBottomSheetOpen = true;
    _extraPadding = 300; // Space for bottom sheet
    notifyListeners();
  }

  /// Called when a bottom sheet is closed
  void onBottomSheetClosed() {
    _isBottomSheetOpen = false;
    _extraPadding = 0;
    notifyListeners();
  }

  /// Convenience method to wrap a showModalBottomSheet call
  Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget Function(BuildContext) builder,
  }) async {
    onBottomSheetOpened();
    final result = await showModalBottomSheet<T>(
      context: context,
      builder: builder,
    );
    onBottomSheetClosed();
    return result;
  }
}

/// Extension to easily use BottomSheetVisibility with any context
extension BottomSheetVisibilityExtension on BuildContext {
  BottomSheetVisibility get bottomSheetVisibility => BottomSheetVisibility();

  Future<T?> showBottomSheetWithMove<T>({
    required Widget Function(BuildContext) builder,
  }) {
    return bottomSheetVisibility.showBottomSheet<T>(
      context: this,
      builder: builder,
    );
  }
}
