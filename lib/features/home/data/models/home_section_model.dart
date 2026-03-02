import '../../domain/entities/home_section.dart';
import 'home_content_item_model.dart';

/// Modelo para HomeSection
class HomeSectionModel extends HomeSection {
  const HomeSectionModel({required super.title, required super.contents});

  factory HomeSectionModel.fromJson(Map<String, dynamic> json) {
    return HomeSectionModel(
      title: json['title'] as String? ?? '',
      contents:
          (json['contents'] as List<dynamic>?)
              ?.map(
                (item) =>
                    HomeContentItemModel.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'contents': contents
          .map((c) => (c as HomeContentItemModel).toJson())
          .toList(),
    };
  }
}
