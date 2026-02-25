part of 'mood_genre_cubit.dart';

/// Estados del cubit de mood/genre
enum MoodGenreStatus {
  initial,
  loading,
  success,
  failure,
}

/// Estado del cubit de mood/genre
class MoodGenreState {
  final MoodGenreStatus status;
  final MoodPlaylistsResponse? response;
  final String? errorMessage;

  const MoodGenreState({
    this.status = MoodGenreStatus.initial,
    this.response,
    this.errorMessage,
  });

  MoodGenreState copyWith({
    MoodGenreStatus? status,
    MoodPlaylistsResponse? response,
    String? errorMessage,
  }) {
    return MoodGenreState(
      status: status ?? this.status,
      response: response ?? this.response,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
