import '../../domain/entities/mood_genre.dart';

/// Modelo para MoodGenre
///
/// La API retorna 'title' en lugar de 'name'
class MoodGenreModel extends MoodGenre {
  const MoodGenreModel({
    required super.title,
    required super.params,
  });

  factory MoodGenreModel.fromJson(Map<String, dynamic> json) {
    return MoodGenreModel(
      title: json['title'] as String? ?? json['name'] as String? ?? '',
      params: json['params'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'params': params,
    };
  }
}
