import 'package:dio/dio.dart';
import 'package:music_app/core/services/network/api_services.dart';

/// Settings del usuario
class UserSettings {
  final String language;
  final String streamingQuality;
  final String downloadQuality;
  final bool autoPlay;
  final bool showLyrics;
  final String equalizerPreset;

  const UserSettings({
    this.language = 'en',
    this.streamingQuality = 'high',
    this.downloadQuality = 'high',
    this.autoPlay = true,
    this.showLyrics = false,
    this.equalizerPreset = 'flat',
  });

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    return UserSettings(
      language: json['language'] ?? 'en',
      streamingQuality: json['streamingQuality'] ?? 'high',
      downloadQuality: json['downloadQuality'] ?? 'high',
      autoPlay: json['autoPlay'] ?? true,
      showLyrics: json['showLyrics'] ?? false,
      equalizerPreset: json['equalizerPreset'] ?? 'flat',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'language': language,
      'streamingQuality': streamingQuality,
      'downloadQuality': downloadQuality,
      'autoPlay': autoPlay,
      'showLyrics': showLyrics,
      'equalizerPreset': equalizerPreset,
    };
  }

  UserSettings copyWith({
    String? language,
    String? streamingQuality,
    String? downloadQuality,
    bool? autoPlay,
    bool? showLyrics,
    String? equalizerPreset,
  }) {
    return UserSettings(
      language: language ?? this.language,
      streamingQuality: streamingQuality ?? this.streamingQuality,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      autoPlay: autoPlay ?? this.autoPlay,
      showLyrics: showLyrics ?? this.showLyrics,
      equalizerPreset: equalizerPreset ?? this.equalizerPreset,
    );
  }
}

/// Perfil del usuario
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
    required this.provider, required this.role, required this.isEmailVerified, this.firstName,
    this.lastName,
    this.avatar,
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

/// Servicio de perfil de usuario.
///
/// Este servicio maneja las operaciones CRUD para el perfil del usuario.
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

  Future<UserProfile> updateProfile({
    String? name,
    String? email,
    String? avatar,
  }) async {
    try {
      final response = await _apiServices.put(
        '/auth/me',
        data: {
          if (name != null) 'name': name,
          if (email != null) 'email': email,
          if (avatar != null) 'avatar': avatar,
        },
      );
      final data = response is Response ? response.data : response;
      return UserProfile.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserSettings> getSettings() async {
    try {
      final response = await _apiServices.get('/users/me/settings');
      final data = response is Response ? response.data : response;
      return UserSettings.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<UserSettings> updateSettings(UserSettings settings) async {
    try {
      final response = await _apiServices.put(
        '/users/me/settings',
        data: settings.toJson(),
      );
      final data = response is Response ? response.data : response;
      return UserSettings.fromJson(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _apiServices.post('/auth/logout');
    } catch (e) {
      rethrow;
    }
  }
}
