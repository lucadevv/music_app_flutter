/// SOLID: Dependency Inversion Principle (DIP)
/// 
/// Esta interfaz abstracta define el contrato para servicios de red.
/// Las clases de alto nivel (repositorios, use cases) dependen de esta abstracción,
/// no de implementaciones concretas (como DioApiServicesImpl).
/// Esto permite cambiar la implementación (Dio, http, etc.) sin afectar el código cliente.
abstract class ApiServices {
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });

  Future<dynamic> post(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isFormData = false,
  });

  Future<dynamic> put(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
    bool isFormData = false,
  });

  Future<dynamic> delete(
    String endpoint, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Map<String, String>? headers,
  });
}
