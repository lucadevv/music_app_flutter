part of 'profile_cubit.dart';

class ProfileState {
  final bool isLoading;
  final String? error;
  final String id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? avatarUrl;
  final String provider;
  final String role;
  final bool isEmailVerified;
  final DateTime? createdAt;
  
  // Settings
  final UserSettings? settings;
  final bool isSettingsLoading;
  final String? settingsError;

  const ProfileState({
    this.isLoading = false,
    this.error,
    this.id = '',
    this.email = '',
    this.firstName,
    this.lastName,
    this.avatarUrl,
    this.provider = 'email',
    this.role = 'user',
    this.isEmailVerified = false,
    this.createdAt,
    this.settings,
    this.isSettingsLoading = false,
    this.settingsError,
  });

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
    return email.isNotEmpty ? email[0].toUpperCase() : '?';
  }

  ProfileState copyWith({
    bool? isLoading,
    String? error,
    String? id,
    String? email,
    String? firstName,
    String? lastName,
    String? avatarUrl,
    String? provider,
    String? role,
    bool? isEmailVerified,
    DateTime? createdAt,
    UserSettings? settings,
    bool? isSettingsLoading,
    String? settingsError,
    bool clearError = false,
    bool clearSettingsError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      id: id ?? this.id,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      provider: provider ?? this.provider,
      role: role ?? this.role,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      createdAt: createdAt ?? this.createdAt,
      settings: settings ?? this.settings,
      isSettingsLoading: isSettingsLoading ?? this.isSettingsLoading,
      settingsError: clearSettingsError ? null : (settingsError ?? this.settingsError),
    );
  }
}
