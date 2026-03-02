import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/queue/domain/entities/queue_entity.dart';

/// Repository interface for queue operations.
/// Note: Queue is managed by PlayerBloc in dashboard feature.
/// This repository provides a simplified interface for queue data.
abstract class QueueRepository {
  /// Get current queue state
  /// Note: This returns a basic representation - actual state managed by PlayerBloc
  Future<Either<AppException, QueueEntity>> getQueue();
}
