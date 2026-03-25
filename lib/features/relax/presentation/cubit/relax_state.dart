import 'package:equatable/equatable.dart';
import 'package:music_app/features/relax/domain/entities/relax_entity.dart';

enum RelaxStatus { initial, loading, success, failure }

class RelaxState extends Equatable {
  final RelaxStatus status;
  final List<RelaxPlaylistEntity> playlists;
  final int selectedCategoryIndex;
  final String? errorMessage;

  const RelaxState({
    this.status = RelaxStatus.initial,
    this.playlists = const [],
    this.selectedCategoryIndex = 0,
    this.errorMessage,
  });

  RelaxState copyWith({
    RelaxStatus? status,
    List<RelaxPlaylistEntity>? playlists,
    int? selectedCategoryIndex,
    String? errorMessage,
  }) {
    return RelaxState(
      status: status ?? this.status,
      playlists: playlists ?? this.playlists,
      selectedCategoryIndex:
          selectedCategoryIndex ?? this.selectedCategoryIndex,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    playlists,
    selectedCategoryIndex,
    errorMessage,
  ];
}
