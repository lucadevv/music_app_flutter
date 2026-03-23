import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/player/domain/player_engine.dart';

class PlaySongUseCase {
  final PlayerEngine _engine;

  PlaySongUseCase(this._engine);

  Future<Either<AppException, void>> call() async {
    try {
      await _engine.play();
      return const Right(null);
    } catch (e) {
      return Left(UnknownException('Failed to play: $e'));
    }
  }
}
