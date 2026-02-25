class MapperException implements Exception {
  final String message;

  MapperException(this.message);

  @override
  String toString() => 'MapperException: $message';
}
