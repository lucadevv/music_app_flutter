/// Entidad del dominio para el usuario
class User {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String? avatar;
  final String role;
  final bool isEmailVerified;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isEmailVerified,
    this.avatar,
  });
}
