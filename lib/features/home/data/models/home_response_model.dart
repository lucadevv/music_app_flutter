import 'package:flutter/foundation.dart';
import '../../domain/entities/home_response.dart';
import 'chart_song_model.dart';
import 'mood_genre_model.dart';
import 'home_section_model.dart';

/// Modelo para HomeResponse
/// 
/// Actualizado según nueva estructura de API:
/// - moods: Array de moods
/// - genres: Array de géneros
/// - charts: Objeto con top_songs y trending (cada uno con stream_url y thumbnail)
/// - sections: Array opcional de secciones de contenido
class HomeResponseModel extends HomeResponse {
  const HomeResponseModel({
    required super.moods,
    required super.genres,
    required super.charts,
    super.sections,
  });

  factory HomeResponseModel.fromJson(Map<String, dynamic> json) {
    // La API retorna 'moods_genres' como array combinado
    // Los primeros 12 items son moods, el resto son genres
    final moodsGenresList = (json['moods_genres'] as List<dynamic>?) ?? [];
    final moods = <MoodGenreModel>[];
    final genres = <MoodGenreModel>[];
    
    // Separar moods y genres (primeros 12 son moods según el ejemplo del API)
    // Nota: Esto es una aproximación. Si la API cambia, necesitaremos otro criterio
    for (var i = 0; i < moodsGenresList.length; i++) {
      try {
        final item = moodsGenresList[i];
        if (item is Map<String, dynamic>) {
          final moodGenre = MoodGenreModel.fromJson(item);
          // Los primeros 12 son moods, el resto son genres
          if (i < 12) {
            moods.add(moodGenre);
          } else {
            genres.add(moodGenre);
          }
        }
      } catch (e, stackTrace) {
        debugPrint('HomeResponseModel: Error parseando mood/genre $i: $e');
        debugPrint('HomeResponseModel: Stack trace: $stackTrace');
      }
    }

    // Parsear charts
    final chartsData = json['charts'] as Map<String, dynamic>? ?? {};
    final topSongs = (chartsData['top_songs'] as List<dynamic>?)
            ?.map((item) => ChartSongModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];
    final trending = (chartsData['trending'] as List<dynamic>?)
            ?.map((item) => ChartSongModel.fromJson(item as Map<String, dynamic>))
            .toList() ??
        [];

    // La API retorna 'home' como array de secciones, no 'sections'
    final sectionsList = json['home'] as List<dynamic>?;
    final sections = <HomeSectionModel>[];
    
    if (sectionsList != null) {
      for (var i = 0; i < sectionsList.length; i++) {
        try {
          final sectionItem = sectionsList[i];
          if (sectionItem is Map<String, dynamic>) {
            sections.add(HomeSectionModel.fromJson(sectionItem));
          } else {
            debugPrint('HomeResponseModel: Section $i no es Map, tipo: ${sectionItem.runtimeType}');
          }
        } catch (e, stackTrace) {
          debugPrint('HomeResponseModel: Error parseando section $i: $e');
          debugPrint('HomeResponseModel: Stack trace: $stackTrace');
        }
      }
    }

    debugPrint('HomeResponseModel: Parseado - moods: ${moods.length}, genres: ${genres.length}, sections: ${sections.length}');

    return HomeResponseModel(
      moods: moods,
      genres: genres,
      charts: Charts(
        topSongs: topSongs,
        trending: trending,
      ),
      sections: sections,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'moods': moods.map((m) => (m as MoodGenreModel).toJson()).toList(),
      'genres': genres.map((g) => (g as MoodGenreModel).toJson()).toList(),
      'charts': {
        'top_songs': charts.topSongs.map((s) => (s as ChartSongModel).toJson()).toList(),
        'trending': charts.trending.map((s) => (s as ChartSongModel).toJson()).toList(),
      },
      'sections': sections.map((s) => (s as HomeSectionModel).toJson()).toList(),
    };
  }
}
