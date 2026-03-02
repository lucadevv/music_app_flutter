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
  final String? title;
  final String? artist;
  final String? thumbnail;
  final int? duration;
  final DateTime? addedAt;

  const FavoriteSongEntity({
    required this.videoId,
    this.title,
    this.artist,
    this.thumbnail,
    this.duration,
    this.addedAt,
  });

  @override
  List<Object?> get props => [videoId, title, artist, thumbnail, duration, addedAt];
}

/// Domain entity for a favorite playlist
class FavoritePlaylistEntity extends Equatable {
  final String id;
  final String? name;
  final String? thumbnail;
  final String? description;
  final int? trackCount;

  const FavoritePlaylistEntity({
    required this.id,
    this.name,
    this.thumbnail,
    this.description,
    this.trackCount,
  });

  @override
  List<Object?> get props => [id, name, thumbnail, description, trackCount];
}

/// Domain entity for a favorite genre
class FavoriteGenreEntity extends Equatable {
  final String id;
  final String? name;
  final String? params;

  const FavoriteGenreEntity({
    required this.id,
    this.name,
    this.params,
  });

  @override
  List<Object?> get props => [id, name, params];
}
