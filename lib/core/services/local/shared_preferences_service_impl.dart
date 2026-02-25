import 'package:music_app/core/services/local/local_storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// SOLID: Single Responsibility Principle (SRP)
///
/// Esta clase tiene una única responsabilidad: implementar la lógica
/// de almacenamiento local usando SharedPreferences. No maneja UI,
/// no maneja lógica de negocio, solo encapsula la comunicación con SharedPreferences.
///
/// SOLID: Open/Closed Principle (OCP)
///
/// Esta implementación está abierta para extensión (se puede heredar)
/// pero cerrada para modificación. Si en el futuro necesitamos cambiar
/// a flutter_secure_storage, Hive o SQFlite, solo necesitamos crear
/// una nueva implementación de LocalStorageService sin modificar este código.
class SharedPreferencesServiceImpl implements LocalStorageService {
  SharedPreferences? _prefs;

  /// Inicializa SharedPreferences
  Future<void> _init() async {
    _prefs ??= await SharedPreferences.getInstance();
  }

  @override
  Future<bool> setString(String key, String value) async {
    await _init();
    try {
      return await _prefs!.setString(key, value);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<String?> getString(String key) async {
    await _init();
    try {
      return _prefs!.getString(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setBool(String key, bool value) async {
    await _init();
    try {
      return await _prefs!.setBool(key, value);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool?> getBool(String key) async {
    await _init();
    try {
      return _prefs!.getBool(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> setInt(String key, int value) async {
    await _init();
    try {
      return await _prefs!.setInt(key, value);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<int?> getInt(String key) async {
    await _init();
    try {
      return _prefs!.getInt(key);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> remove(String key) async {
    await _init();
    try {
      return await _prefs!.remove(key);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> clear() async {
    await _init();
    try {
      return await _prefs!.clear();
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> containsKey(String key) async {
    await _init();
    try {
      return _prefs!.containsKey(key);
    } catch (e) {
      return false;
    }
  }
}
