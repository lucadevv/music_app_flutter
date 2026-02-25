import 'home_content_item.dart';

/// Entidad para secciones del home
class HomeSection {
  final String title;
  final List<HomeContentItem> contents;

  const HomeSection({
    required this.title,
    required this.contents,
  });
}
