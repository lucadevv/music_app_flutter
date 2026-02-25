import 'user.dart';

/// Entidad del dominio para la respuesta de registro
class RegisterResponse {
  final String accessToken;
  final String refreshToken;
  final int expiresIn;
  final User user;

  const RegisterResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.expiresIn,
    required this.user,
  });
}
