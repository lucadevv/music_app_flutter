import 'package:dartz/dartz.dart';
import 'package:music_app/features/queue/data/datasources/queue_data_source.dart';
import 'package:music_app/features/queue/domain/entities/queue_entity.dart';
import 'package:music_app/features/queue/domain/repositories/queue_repository.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';

/// Implementation of QueueRepository.
class QueueRepositoryImpl implements QueueRepository {
  final QueueDataSource _dataSource;

  QueueRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, QueueEntity>> getQueue() async {
    try {
      final queue = await _dataSource.getQueue();
      return Right(queue);
    } catch (e) {
      return Left(UnknownException(e.toString()));
    }
  }
}
