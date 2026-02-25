import '../../domain/entities/mood_genre.dart';

/// Modelo para MoodGenre
/// 
/// La API retorna 'title' en lugar de 'name'
class MoodGenreModel extends MoodGenre {
  const MoodGenreModel({
    required super.name,
    required super.params,
  });

  factory MoodGenreModel.fromJson(Map<String, dynamic> json) {
    return MoodGenreModel(
      // La API retorna 'title', pero la entidad usa 'name'
      name: json['title'] as String? ?? json['name'] as String? ?? '',
      params: json['params'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': name, // API espera 'title'
      'params': params,
    };
  }
}
