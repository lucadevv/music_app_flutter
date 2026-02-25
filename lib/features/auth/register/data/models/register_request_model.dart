import '../../domain/entities/register_request.dart';

/// Modelo de datos para la solicitud de registro
class RegisterRequestModel extends RegisterRequest {
  const RegisterRequestModel({
    required super.email,
    required super.password,
    required super.firstName,
    required super.lastName,
  });

  /// Convierte el modelo a Map (JSON) para enviar al servidor
  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'firstName': firstName,
      'lastName': lastName,
    };
  }
}
