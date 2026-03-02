part of 'album_cubit.dart';

enum AlbumStatus { initial, loading, success, failure }

class AlbumState {
  final AlbumStatus status;
  final Album? album;
  final List<AlbumSong> songs;
  final bool isLiked;
  final String? errorMessage;

  const AlbumState({
    this.status = AlbumStatus.initial,
    this.album,
    this.songs = const [],
    this.isLiked = false,
    this.errorMessage,
  });

  AlbumState copyWith({
    AlbumStatus? status,
    Album? album,
    List<AlbumSong>? songs,
    bool? isLiked,
    String? errorMessage,
  }) {
    return AlbumState(
      status: status ?? this.status,
      album: album ?? this.album,
      songs: songs ?? this.songs,
      isLiked: isLiked ?? this.isLiked,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
