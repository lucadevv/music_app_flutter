part of 'orquestador_home_cubit.dart';

/// Effects para el flujo del home
sealed class OrquestadorHomeEffect extends Equatable {
  const OrquestadorHomeEffect();

  @override
  List<Object?> get props => [];
}

class ShowErrorEffect extends OrquestadorHomeEffect {
  final String message;

  const ShowErrorEffect(this.message);

  @override
  List<Object?> get props => [message];
}
