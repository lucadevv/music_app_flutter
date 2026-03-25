import 'package:equatable/equatable.dart';

/// Domain entity representing library summary
class LibrarySummaryEntity extends Equatable {
  final int favoriteSongsCount;
  final int favoritePlaylistsCount;
  final int favoriteGenresCount;
  final List<String>? recentlyPlayed;

  const LibrarySummaryEntity({
    this.favoriteSongsCount = 0,
    this.favoritePlaylistsCount = 0,
    this.favoriteGenresCount = 0,
    this.recentlyPlayed,
  });

  @override
  List<Object?> get props => [
    favoriteSongsCount,
    favoritePlaylistsCount,
    favoriteGenresCount,
    recentlyPlayed,
  ];
}

/// Domain entity for a favorite song in library
class FavoriteSongEntity extends Equatable {
  final String videoId;
  final String songId;
  final String? title;
  final String? artist;
  final String? thumbnail;
  final int? duration;
  final DateTime? addedAt;

  const FavoriteSongEntity({
    required this.videoId,
    required this.songId,
    this.title,
    this.artist,
    this.thumbnail,
    this.duration,
    this.addedAt,
  });

  @override
  List<Object?> get props => [
    videoId,
    songId,
    title,
    artist,
    thumbnail,
    duration,
    addedAt,
  ];
}

/// Domain entity for a favorite playlist
class FavoritePlaylistEntity extends Equatable {
  final String id;
  final String externalPlaylistId;
  final String? name;
  final String? thumbnail;
  final String? description;
  final int? trackCount;

  const FavoritePlaylistEntity({
    required this.id,
    required this.externalPlaylistId,
    this.name,
    this.thumbnail,
    this.description,
    this.trackCount,
  });

  @override
  List<Object?> get props => [
    id,
    externalPlaylistId,
    name,
    thumbnail,
    description,
    trackCount,
  ];
}

/// Domain entity for a favorite genre
class FavoriteGenreEntity extends Equatable {
  final String id;
  final String externalParams;
  final String? name;

  const FavoriteGenreEntity({
    required this.id,
    required this.externalParams,
    this.name,
  });

  @override
  List<Object?> get props => [id, externalParams, name];
}

/// Response entity containing songs with their ID mapping
/// Used by FavoriteCubit to maintain videoId -> songId mapping for removal
class FavoriteSongsWithMapping extends Equatable {
  final List<FavoriteSongEntity> songs;
  final Map<String, String> songIdByVideoId;

  const FavoriteSongsWithMapping({
    required this.songs,
    required this.songIdByVideoId,
  });

  @override
  List<Object?> get props => [songs, songIdByVideoId];
}
