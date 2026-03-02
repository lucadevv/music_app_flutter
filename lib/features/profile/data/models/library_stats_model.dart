import 'package:music_app/features/profile/domain/entities/library_stats_entity.dart';

/// Data model for LibraryStats from API responses.
class LibraryStatsModel {
  final int favoriteSongsCount;
  final int favoritePlaylistsCount;
  final int favoriteGenresCount;

  const LibraryStatsModel({
    this.favoriteSongsCount = 0,
    this.favoritePlaylistsCount = 0,
    this.favoriteGenresCount = 0,
  });

  factory LibraryStatsModel.fromJson(Map<String, dynamic> json) {
    return LibraryStatsModel(
      favoriteSongsCount: json['favoriteSongsCount'] ?? 0,
      favoritePlaylistsCount: json['favoritePlaylistsCount'] ?? 0,
      favoriteGenresCount: json['favoriteGenresCount'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'favoriteSongsCount': favoriteSongsCount,
      'favoritePlaylistsCount': favoritePlaylistsCount,
      'favoriteGenresCount': favoriteGenresCount,
    };
  }

  /// Convert model to domain entity
  LibraryStatsEntity toEntity() {
    return LibraryStatsEntity(
      favoriteSongsCount: favoriteSongsCount,
      favoritePlaylistsCount: favoritePlaylistsCount,
      favoriteGenresCount: favoriteGenresCount,
    );
  }

  /// Create model from domain entity
  factory LibraryStatsModel.fromEntity(LibraryStatsEntity entity) {
    return LibraryStatsModel(
      favoriteSongsCount: entity.favoriteSongsCount,
      favoritePlaylistsCount: entity.favoritePlaylistsCount,
      favoriteGenresCount: entity.favoriteGenresCount,
    );
  }
}
