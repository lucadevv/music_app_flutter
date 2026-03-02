import 'package:music_app/features/queue/domain/entities/queue_entity.dart';

/// Data source for queue operations.
/// Note: Actual queue is managed by PlayerBloc - this provides basic interface.
class QueueDataSource {
  /// Get current queue (delegates to PlayerBloc state in presentation)
  /// This is a placeholder - actual implementation would integrate with PlayerBloc
  Future<QueueEntity> getQueue() async {
    // Queue is managed by PlayerBloc in presentation layer
    // This returns an empty queue as placeholder
    return const QueueEntity();
  }
}
