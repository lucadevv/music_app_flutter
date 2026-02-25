/// SOLID: Dependency Inversion Principle (DIP)
/// 
/// Esta interfaz abstracta define el contrato para el servicio de almacenamiento local.
/// Las clases de alto nivel (presentation, use cases) dependen de esta abstracción,
/// no de implementaciones concretas (SharedPreferences, Hive, SQFlite, etc.).
/// 
/// Esto permite cambiar la implementación sin afectar el código cliente.
/// Ejemplo: Cambiar de SharedPreferences a flutter_secure_storage o Hive
/// solo requiere crear una nueva implementación e inyectarla.
abstract class LocalStorageService {
  /// Guarda un valor String con una clave
  Future<bool> setString(String key, String value);

  /// Obtiene un valor String por su clave
  /// Retorna null si no existe
  Future<String?> getString(String key);

  /// Guarda un valor bool con una clave
  Future<bool> setBool(String key, bool value);

  /// Obtiene un valor bool por su clave
  /// Retorna null si no existe
  Future<bool?> getBool(String key);

  /// Guarda un valor int con una clave
  Future<bool> setInt(String key, int value);

  /// Obtiene un valor int por su clave
  /// Retorna null si no existe
  Future<int?> getInt(String key);

  /// Elimina un valor por su clave
  Future<bool> remove(String key);

  /// Elimina todos los valores almacenados
  Future<bool> clear();

  /// Verifica si existe una clave
  Future<bool> containsKey(String key);
}
