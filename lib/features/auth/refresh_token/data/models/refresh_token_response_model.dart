import '../../domain/entities/refresh_token_response.dart';

/// Modelo de datos para la respuesta de refresh token
class RefreshTokenResponseModel extends RefreshTokenResponse {
  const RefreshTokenResponseModel({
    required super.accessToken,
    required super.refreshToken,
    required super.isEmailVerified,
  });

  /// Crea un RefreshTokenResponseModel desde un Map (JSON)
  factory RefreshTokenResponseModel.fromJson(Map<String, dynamic> json) {
    return RefreshTokenResponseModel(
      accessToken: json['accessToken'] as String,
      refreshToken: json['refreshToken'] as String,
      isEmailVerified: json['user']?['isEmailVerified'] as bool? ?? false,
    );
  }

  /// Convierte el modelo a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'accessToken': accessToken,
      'refreshToken': refreshToken,
      'isEmailVerified': isEmailVerified,
    };
  }
}
