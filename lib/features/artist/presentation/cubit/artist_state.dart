part of 'artist_cubit.dart';

enum ArtistStatus { initial, loading, success, failure }

class ArtistState {
  final ArtistStatus status;
  final Artist? artist;
  final List<ArtistSong> topSongs;
  final List<ArtistAlbum> albums;
  final bool isFollowing;
  final String? errorMessage;

  const ArtistState({
    this.status = ArtistStatus.initial,
    this.artist,
    this.topSongs = const [],
    this.albums = const [],
    this.isFollowing = false,
    this.errorMessage,
  });

  ArtistState copyWith({
    ArtistStatus? status,
    Artist? artist,
    List<ArtistSong>? topSongs,
    List<ArtistAlbum>? albums,
    bool? isFollowing,
    String? errorMessage,
  }) {
    return ArtistState(
      status: status ?? this.status,
      artist: artist ?? this.artist,
      topSongs: topSongs ?? this.topSongs,
      albums: albums ?? this.albums,
      isFollowing: isFollowing ?? this.isFollowing,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
