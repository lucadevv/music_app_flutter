import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/player/domain/player_engine.dart';

class PauseSongUseCase {
  final PlayerEngine _engine;

  PauseSongUseCase(this._engine);

  Future<Either<AppException, void>> call() async {
    try {
      await _engine.pause();
      return const Right(null);
    } catch (e) {
      return Left(UnknownException('Failed to pause: $e'));
    }
  }
}
