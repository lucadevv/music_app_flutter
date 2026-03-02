import 'package:music_app/features/auth/register/data/models/user_model.dart';

import '../../register/domain/entities/register_response.dart';

/// Request para autenticación OAuth
class OAuthRequest {
  final String provider;
  final String accessToken;
  final String? idToken;
  final String? email;
  final String? name;

  const OAuthRequest({
    required this.provider,
    required this.accessToken,
    this.idToken,
    this.email,
    this.name,
  });

  Map<String, dynamic> toJson() => {
    'provider': provider,
    'access_token': accessToken,
    if (idToken != null) 'id_token': idToken,
    if (email != null) 'email': email,
    if (name != null) 'name': name,
  };
}

/// Response para autenticación OAuth
/// Extiende de RegisterResponse ya que la estructura es la misma
class OAuthResponse extends RegisterResponse {
  final bool isNewUser;

  const OAuthResponse({
    required super.accessToken,
    required super.refreshToken,
    required super.expiresIn,
    required super.user,
    this.isNewUser = false,
  });

  factory OAuthResponse.fromJson(Map<String, dynamic> json) {
    return OAuthResponse(
      accessToken:
          json['accessToken'] as String? ??
          json['access_token'] as String? ??
          '',
      refreshToken:
          json['refreshToken'] as String? ??
          json['refresh_token'] as String? ??
          '',
      expiresIn:
          json['expiresIn'] as int? ?? json['expires_in'] as int? ?? 3600,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      isNewUser:
          json['isNewUser'] as bool? ?? json['is_new_user'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'expiresIn': expiresIn,
    'user': (user as UserModel).toJson(),
    'isNewUser': isNewUser,
  };
}
