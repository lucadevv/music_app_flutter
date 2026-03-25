part of 'liked_songs_cubit.dart';

enum LikedSongsStatus { initial, loading, success, failure }

class LikedSongsState {
  final LikedSongsStatus status;
  final String? errorMessage;
  final List<FavoriteSong> songs;
  final int totalSongs;
  final bool isLoadingMore;

  const LikedSongsState({
    this.status = LikedSongsStatus.initial,
    this.errorMessage,
    this.songs = const [],
    this.totalSongs = 0,
    this.isLoadingMore = false,
  });

  bool get hasMoreSongs => songs.length < totalSongs;
  bool get isEmpty => songs.isEmpty;

  LikedSongsState copyWith({
    LikedSongsStatus? status,
    String? errorMessage,
    List<FavoriteSong>? songs,
    int? totalSongs,
    bool? isLoadingMore,
    bool clearError = false,
  }) {
    return LikedSongsState(
      status: status ?? this.status,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      songs: songs ?? this.songs,
      totalSongs: totalSongs ?? this.totalSongs,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
    );
  }
}
