/// Entidad del dominio para la solicitud de login
class LoginRequest {
  final String email;
  final String password;

  const LoginRequest({required this.email, required this.password});
}
