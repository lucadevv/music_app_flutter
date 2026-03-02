part of 'recently_played_cubit.dart';

enum RecentlyPlayedStatus { initial, loading, success, failure }

class RecentlyPlayedState extends Equatable {
  final RecentlyPlayedStatus status;
  final List<RecentlyPlayedSong> songs;
  final String? errorMessage;

  const RecentlyPlayedState({
    this.status = RecentlyPlayedStatus.initial,
    this.songs = const [],
    this.errorMessage,
  });

  RecentlyPlayedState copyWith({
    RecentlyPlayedStatus? status,
    List<RecentlyPlayedSong>? songs,
    String? errorMessage,
    bool clearError = false,
  }) {
    return RecentlyPlayedState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, songs, errorMessage];
}
