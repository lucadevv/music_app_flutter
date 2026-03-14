import 'home_content_item.dart';

/// Entidad para secciones del home
class HomeSection {
  final String title;
  final List<HomeContentItem> contents;

  const HomeSection({required this.title, required this.contents});

  HomeSection copyWith({
    String? title,
    List<HomeContentItem>? contents,
  }) {
    return HomeSection(
      title: title ?? this.title,
      contents: contents ?? this.contents,
    );
  }
}
