import 'package:equatable/equatable.dart';

/// Tipo de playlist
enum PlaylistType { user, favorite }

/// Modelo de item de playlist
class PlaylistItem {
  final String id;
  final String name;
  final String? thumbnail;
  final int songCount;
  final PlaylistType type;
  final String? externalId;

  const PlaylistItem({
    required this.id,
    required this.name,
    required this.songCount,
    required this.type,
    this.thumbnail,
    this.externalId,
  });
}

/// Estados del UserPlaylistsCubit
enum UserPlaylistsStatus { initial, loading, success, failure }

/// Estado de playlists de usuario
class UserPlaylistsState extends Equatable {
  final UserPlaylistsStatus status;
  final List<PlaylistItem> playlists;
  final String? errorMessage;

  const UserPlaylistsState({
    this.status = UserPlaylistsStatus.initial,
    this.playlists = const [],
    this.errorMessage,
  });

  UserPlaylistsState copyWith({
    UserPlaylistsStatus? status,
    List<PlaylistItem>? playlists,
    String? errorMessage,
  }) {
    return UserPlaylistsState(
      status: status ?? this.status,
      playlists: playlists ?? this.playlists,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, playlists, errorMessage];
}
