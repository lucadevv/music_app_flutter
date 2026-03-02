import 'package:music_app/features/profile/domain/entities/user_profile_entity.dart';

/// Data model for UserProfile from API responses.
class UserProfileModel {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String provider;
  final String role;
  final bool isEmailVerified;
  final DateTime? createdAt;

  const UserProfileModel({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    this.provider = 'email',
    this.role = 'user',
    this.isEmailVerified = false,
    this.createdAt,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] ?? '',
      email: json['email'] ?? '',
      firstName: json['firstName'],
      lastName: json['lastName'],
      avatar: json['avatar'],
      provider: json['provider'] ?? 'email',
      role: json['role'] ?? 'user',
      isEmailVerified: json['isEmailVerified'] ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'firstName': firstName,
      'lastName': lastName,
      'avatar': avatar,
      'provider': provider,
      'role': role,
      'isEmailVerified': isEmailVerified,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  /// Convert model to domain entity
  UserProfileEntity toEntity() {
    return UserProfileEntity(
      id: id,
      email: email,
      firstName: firstName,
      lastName: lastName,
      avatar: avatar,
      provider: provider,
      role: role,
      isEmailVerified: isEmailVerified,
      createdAt: createdAt,
    );
  }

  /// Create model from domain entity
  factory UserProfileModel.fromEntity(UserProfileEntity entity) {
    return UserProfileModel(
      id: entity.id,
      email: entity.email,
      firstName: entity.firstName,
      lastName: entity.lastName,
      avatar: entity.avatar,
      provider: entity.provider,
      role: entity.role,
      isEmailVerified: entity.isEmailVerified,
      createdAt: entity.createdAt,
    );
  }
}
