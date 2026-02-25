/// Entidad del dominio para la respuesta de refresh token
class RefreshTokenResponse {
  final String accessToken;
  final String refreshToken;
  final bool isEmailVerified;

  const RefreshTokenResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.isEmailVerified,
  });
}
