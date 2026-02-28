import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';

/// Servicio para monitorear el estado de conectividad
///
/// Proporciona un stream para detectar cambios en la conexión
/// a internet.
class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  ConnectivityService(this._connectivity) {
    // Escuchar cambios en la conectividad
    _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = !results.contains(ConnectivityResult.none);
      _connectionController.add(isConnected);
    });
  }

  /// Stream que emite true cuando hay conexión y false cuando no
  Stream<bool> get connectionStream => _connectionController.stream;

  /// Verifica si hay conexión a internet
  Future<bool> get isOnline async {
    final result = await _connectivity.checkConnectivity();
    return !result.contains(ConnectivityResult.none);
  }

  /// Cierra el stream controller
  void dispose() {
    _connectionController.close();
  }
}
