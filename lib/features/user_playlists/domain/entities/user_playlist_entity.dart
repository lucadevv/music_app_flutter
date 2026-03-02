import 'package:equatable/equatable.dart';

/// Entity representing a user playlist.
class UserPlaylistEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? thumbnail;
  final int trackCount;
  final bool isOwner;

  const UserPlaylistEntity({
    required this.id,
    required this.name,
    this.description,
    this.thumbnail,
    this.trackCount = 0,
    this.isOwner = true,
  });

  @override
  List<Object?> get props => [id, name, description, thumbnail, trackCount, isOwner];
}
