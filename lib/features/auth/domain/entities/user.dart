import 'package:equatable/equatable.dart';

/// Entidad pura de dominio para el Usuario.
/// No debe contener lógica de serialización ni dependencias de frameworks externos.
class User extends Equatable {
  final String id;
  final String email;
  final String firstName;
  final String lastName;
  final String role;
  final bool isEmailVerified;
  final String? avatar;

  const User({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.role,
    required this.isEmailVerified,
    this.avatar,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    firstName,
    lastName,
    role,
    isEmailVerified,
    avatar,
  ];
}
