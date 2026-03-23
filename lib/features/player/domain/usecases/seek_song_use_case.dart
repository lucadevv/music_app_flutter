import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import 'package:music_app/features/player/domain/player_engine.dart';

class SeekSongUseCase {
  final PlayerEngine _engine;

  SeekSongUseCase(this._engine);

  Future<Either<AppException, void>> call(Duration position) async {
    try {
      await _engine.seek(position);
      return const Right(null);
    } catch (e) {
      return Left(UnknownException('Failed to seek: $e'));
    }
  }
}
