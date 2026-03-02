import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/queue/domain/entities/queue_entity.dart';
import 'package:music_app/features/queue/domain/repositories/queue_repository.dart';

/// Use case for getting queue state.
/// Note: Queue is primarily managed by PlayerBloc in dashboard feature.
class GetQueueUseCase {
  final QueueRepository _repository;

  GetQueueUseCase(this._repository);

  Future<Either<AppException, QueueEntity>> call() {
    return _repository.getQueue();
  }
}
