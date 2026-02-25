import '../../domain/entities/thumbnail.dart';

/// Modelo de datos para las miniaturas
class ThumbnailModel extends Thumbnail {
  const ThumbnailModel({
    required super.url,
    required super.width,
    required super.height,
  });

  factory ThumbnailModel.fromJson(Map<String, dynamic> json) {
    return ThumbnailModel(
      url: json['url'] as String? ?? '',
      width: json['width'] as int? ?? 0,
      height: json['height'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'url': url,
      'width': width,
      'height': height,
    };
  }
}
