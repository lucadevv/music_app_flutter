import 'package:equatable/equatable.dart';

/// Entity representing user settings in the domain layer.
class UserSettingsEntity extends Equatable {
  final String language;
  final String streamingQuality;
  final String downloadQuality;
  final bool autoPlay;
  final bool showLyrics;
  final String equalizerPreset;

  const UserSettingsEntity({
    this.language = 'en',
    this.streamingQuality = 'high',
    this.downloadQuality = 'high',
    this.autoPlay = true,
    this.showLyrics = false,
    this.equalizerPreset = 'flat',
  });

  /// Create entity from JSON map
  factory UserSettingsEntity.fromJson(Map<String, dynamic> json) {
    return UserSettingsEntity(
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

  UserSettingsEntity copyWith({
    String? language,
    String? streamingQuality,
    String? downloadQuality,
    bool? autoPlay,
    bool? showLyrics,
    String? equalizerPreset,
  }) {
    return UserSettingsEntity(
      language: language ?? this.language,
      streamingQuality: streamingQuality ?? this.streamingQuality,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      autoPlay: autoPlay ?? this.autoPlay,
      showLyrics: showLyrics ?? this.showLyrics,
      equalizerPreset: equalizerPreset ?? this.equalizerPreset,
    );
  }

  @override
  List<Object?> get props => [
        language,
        streamingQuality,
        downloadQuality,
        autoPlay,
        showLyrics,
        equalizerPreset,
      ];
}
