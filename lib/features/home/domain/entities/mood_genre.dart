/// Entidad para categorías de moods y géneros
///
/// La API retorna 'title' - se mantiene esa estructura
///
/// SOLID: Single Responsibility Principle (SRP)
/// Responsable única: Representar un mood o género
class MoodGenre {
  final String title; // Cambiado de 'name' a 'title' según API
  final String params;

  const MoodGenre({required this.title, required this.params});
}
