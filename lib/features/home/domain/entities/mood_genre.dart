/// Entidad para categorías de moods y géneros
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar un mood o género
class MoodGenre {
  final String name; // Cambiado de 'title' a 'name' según nueva API
  final String params;

  const MoodGenre({required this.name, required this.params});
}
