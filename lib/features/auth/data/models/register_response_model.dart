import '../../domain/entities/register_response.dart';
import 'user_model.dart';

/// Modelo de datos para la respuesta de registro
class RegisterResponseModel extends RegisterResponse {
  const RegisterResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
    required super.user,
  });

  /// Crea un RegisterResponseModel desde un Map (JSON)
  factory RegisterResponseModel.fromJson(Map<String, dynamic> json) {
    return RegisterResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      expiresIn: json['expiresIn'] as int,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  /// Convierte el modelo a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'expiresIn': expiresIn,
      'user': (user as UserModel).toJson(),
    };
  }
}
