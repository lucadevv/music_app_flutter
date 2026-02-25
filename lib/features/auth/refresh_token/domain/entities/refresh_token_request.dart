/// Entidad del dominio para la solicitud de refresh token
class RefreshTokenRequest {
  final String refreshToken;

  const RefreshTokenRequest({
    required this.refreshToken,
  });
}
