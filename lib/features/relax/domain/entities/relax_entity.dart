import 'package:equatable/equatable.dart';

/// Entity representing a relax/mood playlist.
class RelaxPlaylistEntity extends Equatable {
  final String id;
  final String title;
  final String description;
  final String? thumbnail;
  final String category; // e.g., "morning", "evening", "focus", "sleep"

  const RelaxPlaylistEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.category, this.thumbnail,
  });

  @override
  List<Object?> get props => [id, title, description, thumbnail, category];
}
