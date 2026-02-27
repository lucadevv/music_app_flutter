import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';

class UserProfile {
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatar;
  final String provider;
  final String role;
  final bool isEmailVerified;
  final DateTime? createdAt;

  const UserProfile({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.avatar,
    required this.provider,
    required this.role,
    required this.isEmailVerified,
    this.createdAt,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
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

  String get displayName {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '$firstName $lastName';
      }
      return firstName!;
    }
    // Fallback al email
    return email.split('@')[0].split('.').map((part) => 
      part.isEmpty ? '' : '${part[0].toUpperCase()}${part.substring(1)}'
    ).join(' ');
  }

  String get initials {
    if (firstName != null && firstName!.isNotEmpty) {
      if (lastName != null && lastName!.isNotEmpty) {
        return '${firstName![0]}${lastName![0]}'.toUpperCase();
      }
      return firstName![0].toUpperCase();
    }
    // Fallback al email
    final parts = email.split('@')[0].split('.');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return email[0].toUpperCase();
  }
}

class ProfileService {
  final ApiServices _apiServices;

  ProfileService(this._apiServices);

  Future<UserProfile> getProfile() async {
    try {
      final response = await _apiServices.get('/auth/me');
      final data = response is Response ? response.data : response;
      return UserProfile.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }
}
