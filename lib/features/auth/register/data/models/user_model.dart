import '../../domain/entities/user.dart';

/// Modelo de datos para el usuario
/// Extiende la entidad del dominio y agrega métodos de serialización
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    required super.firstName,
    required super.lastName,
    required super.role, required super.isEmailVerified, super.avatar,
  });

  /// Crea un UserModel desde un Map (JSON)
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      avatar: json['avatar'] as String?,
      role: json['role'] as String,
      isEmailVerified: json['isEmailVerified'] as bool? ?? false,
    );
  }

  /// Convierte el modelo a Map (JSON)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'role': role,
      'isEmailVerified': isEmailVerified,
    };
  }
}
