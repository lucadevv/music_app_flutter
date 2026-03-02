part of 'profile_cubit.dart';

class ProfileState {
  final bool isLoading;
  final String? errorMessage;
  final UserProfile? profile;
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

  // Library Stats
  final bool isLoadingStats;
  final int favoriteSongsCount;
  final int favoritePlaylistsCount;
  final int favoriteGenresCount;

  const ProfileState({
    this.isLoading = false,
    this.errorMessage,
    this.profile,
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
    // Library Stats
    this.isLoadingStats = true,
    this.favoriteSongsCount = 0,
    this.favoritePlaylistsCount = 0,
    this.favoriteGenresCount = 0,
  });

  String get displayName {
    final name = profile?.displayName;
    if (name != null && name.isNotEmpty) return name;
    
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
    final init = profile?.initials;
    if (init != null && init.isNotEmpty) return init;
    
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
    String? errorMessage,
    UserProfile? profile,
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
    // Library Stats
    bool? isLoadingStats,
    int? favoriteSongsCount,
    int? favoritePlaylistsCount,
    int? favoriteGenresCount,
    bool clearError = false,
    bool clearSettingsError = false,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      profile: profile ?? this.profile,
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
      // Library Stats
      isLoadingStats: isLoadingStats ?? this.isLoadingStats,
      favoriteSongsCount: favoriteSongsCount ?? this.favoriteSongsCount,
      favoritePlaylistsCount: favoritePlaylistsCount ?? this.favoritePlaylistsCount,
      favoriteGenresCount: favoriteGenresCount ?? this.favoriteGenresCount,
    );
  }
}
