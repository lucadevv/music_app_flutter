import 'package:equatable/equatable.dart';

/// Entity representing library statistics.
class LibraryStatsEntity extends Equatable {
  final int favoriteSongsCount;
  final int favoritePlaylistsCount;
  final int favoriteGenresCount;

  const LibraryStatsEntity({
    this.favoriteSongsCount = 0,
    this.favoritePlaylistsCount = 0,
    this.favoriteGenresCount = 0,
  });

  @override
  List<Object?> get props => [
        favoriteSongsCount,
        favoritePlaylistsCount,
        favoriteGenresCount,
      ];
}
