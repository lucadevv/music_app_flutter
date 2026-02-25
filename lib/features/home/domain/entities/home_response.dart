import 'chart_song.dart';
import 'mood_genre.dart';
import 'home_section.dart';

/// Entidad para la respuesta completa del endpoint /api/music/explore
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar la respuesta del endpoint de exploración
class HomeResponse {
  final List<MoodGenre> moods;
  final List<MoodGenre> genres;
  final Charts charts;
  final List<HomeSection> sections; // Secciones de contenido (tendencias, etc.)

  const HomeResponse({
    required this.moods,
    required this.genres,
    required this.charts,
    this.sections = const [], // Opcional, por si la API no las retorna
  });
}

/// Entidad para los charts (top_songs y trending)
/// 
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar los charts con canciones
class Charts {
  final List<ChartSong> topSongs;
  final List<ChartSong> trending;

  const Charts({
    required this.topSongs,
    required this.trending,
  });
}
