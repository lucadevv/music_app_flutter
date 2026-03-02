import 'package:music_app/features/profile/domain/entities/user_settings_entity.dart';

/// Data model for UserSettings from API responses.
class UserSettingsModel {
  final String language;
  final String streamingQuality;
  final String downloadQuality;
  final bool autoPlay;
  final bool showLyrics;
  final String equalizerPreset;

  const UserSettingsModel({
    this.language = 'en',
    this.streamingQuality = 'high',
    this.downloadQuality = 'high',
    this.autoPlay = true,
    this.showLyrics = false,
    this.equalizerPreset = 'flat',
  });

  factory UserSettingsModel.fromJson(Map<String, dynamic> json) {
    return UserSettingsModel(
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

  /// Convert model to domain entity
  UserSettingsEntity toEntity() {
    return UserSettingsEntity(
      language: language,
      streamingQuality: streamingQuality,
      downloadQuality: downloadQuality,
      autoPlay: autoPlay,
      showLyrics: showLyrics,
      equalizerPreset: equalizerPreset,
    );
  }

  /// Create model from domain entity
  factory UserSettingsModel.fromEntity(UserSettingsEntity entity) {
    return UserSettingsModel(
      language: entity.language,
      streamingQuality: entity.streamingQuality,
      downloadQuality: entity.downloadQuality,
      autoPlay: entity.autoPlay,
      showLyrics: entity.showLyrics,
      equalizerPreset: entity.equalizerPreset,
    );
  }
}
