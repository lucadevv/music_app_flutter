part of 'similar_songs_cubit.dart';

enum SimilarSongsStatus { initial, loading, success, failure }

class SimilarSongsState extends Equatable {
  final SimilarSongsStatus status;
  final List<RadioTrackEntity> tracks;
  final String? error;

  const SimilarSongsState({
    this.status = SimilarSongsStatus.initial,
    this.tracks = const [],
    this.error,
  });

  SimilarSongsState copyWith({
    SimilarSongsStatus? status,
    List<RadioTrackEntity>? tracks,
    String? error,
  }) {
    return SimilarSongsState(
      status: status ?? this.status,
      tracks: tracks ?? this.tracks,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, tracks, error];
}
