import 'song.dart';

/// Entidad del dominio para una búsqueda reciente
class RecentSearch {
  final String id;
  final String videoId;
  final Song songData;
  final DateTime createdAt;
  final DateTime lastSearchedAt;

  const RecentSearch({
    required this.id,
    required this.videoId,
    required this.songData,
    required this.createdAt,
    required this.lastSearchedAt,
  });
}
