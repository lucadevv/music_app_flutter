import 'package:dartz/dartz.dart';
import 'package:music_app/core/domain/entities/song.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/player/domain/services/history_state_service.dart';

class ManageHistoryUseCase {
  final HistoryStateService _historyStateService;

  ManageHistoryUseCase(this._historyStateService);

  Future<Either<AppException, String?>> startNewEntry(Song song) async {
    try {
      final historyId = await _historyStateService.startNewEntry(song);
      return Right(historyId);
    } catch (e) {
      return Left(UnknownException('Failed to start history entry: $e'));
    }
  }

  Future<Either<AppException, void>> updatePlayedDuration(
    int positionSeconds,
  ) async {
    try {
      await _historyStateService.updatePlayedDuration(positionSeconds);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException('Failed to update played duration: $e'));
    }
  }

  Future<Either<AppException, void>> finalizeCurrent() async {
    try {
      await _historyStateService.finalizeCurrent();
      return const Right(null);
    } catch (e) {
      return Left(UnknownException('Failed to finalize history: $e'));
    }
  }
}
