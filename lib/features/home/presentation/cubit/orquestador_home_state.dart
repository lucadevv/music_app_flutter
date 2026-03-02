part of 'orquestador_home_cubit.dart';

class OrquestadorHomeState extends Equatable {
  final HomeState homeState;
  final MoodGenreState moodGenreState;
  final PlaylistState playlistState;
  final bool hasError;
  final String? errorMessage;
  final OrquestadorHomeEffect? effect;

  const OrquestadorHomeState({
    required this.homeState,
    required this.moodGenreState,
    required this.playlistState,
    this.hasError = false,
    this.errorMessage,
    this.effect,
  });

  OrquestadorHomeState copyWith({
    HomeState? homeState,
    MoodGenreState? moodGenreState,
    PlaylistState? playlistState,
    bool? hasError,
    String? errorMessage,
    OrquestadorHomeEffect? effect,
  }) {
    return OrquestadorHomeState(
      homeState: homeState ?? this.homeState,
      moodGenreState: moodGenreState ?? this.moodGenreState,
      playlistState: playlistState ?? this.playlistState,
      hasError: hasError ?? this.hasError,
      errorMessage: errorMessage,
      effect: effect,
    );
  }

  factory OrquestadorHomeState.initial() => const OrquestadorHomeState(
    homeState: HomeState(),
    moodGenreState: MoodGenreState(),
    playlistState: PlaylistState(),
  );

  @override
  List<Object?> get props => [
    homeState,
    moodGenreState,
    playlistState,
    hasError,
    errorMessage,
    effect,
  ];
}
