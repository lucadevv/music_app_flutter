---
name: bloc-patterns
description: Patrones BLoC/Cubit para este proyecto Flutter de música. OrquestadorCubit, BaseBlocMixin, estados inmutables, manejo de errores con Either. Usar cuando implementes o modifiques cubits/blocs.
---

# BLoC/Cubit Patterns - Music App

## Estructura de un Cubit completo

### State
```dart
// features/xxx/presentation/cubit/xxx_state.dart
import 'package:equatable/equatable.dart';

enum XxxStatus { initial, loading, success, failure }

class XxxState extends Equatable {
  final XxxStatus status;
  final XxxData? data;
  final String? errorMessage;

  const XxxState({
    this.status = XxxStatus.initial,
    this.data,
    this.errorMessage,
  });

  bool get isLoading => status == XxxStatus.loading;
  bool get isSuccess => status == XxxStatus.success;
  bool get isFailure => status == XxxStatus.failure;

  XxxState copyWith({
    XxxStatus? status,
    XxxData? data,
    String? errorMessage,
    bool clearError = false,
  }) {
    return XxxState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, data, errorMessage];
}
```

### Cubit con BaseBlocMixin
```dart
// features/xxx/presentation/cubit/xxx_cubit.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/bloc/base_bloc_mixin.dart';

class XxxCubit extends Cubit<XxxState> with BaseBlocMixin {
  final XxxUseCase _useCase;

  XxxCubit(this._useCase) : super(const XxxState());

  Future<void> loadData(String id) async {
    // Guard: no emitir si el cubit fue cerrado
    if (isClosed) return;
    
    emit(state.copyWith(
      status: XxxStatus.loading,
      clearError: true,  // limpia error anterior
    ));

    final result = await _useCase(id);

    if (isClosed) return;  // verificar de nuevo tras async
    
    result.fold(
      (error) => emit(state.copyWith(
        status: XxxStatus.failure,
        errorMessage: getErrorMessage(error),  // BaseBlocMixin
      )),
      (data) => emit(state.copyWith(
        status: XxxStatus.success,
        data: data,
      )),
    );
  }

  void reset() {
    emit(const XxxState());
  }
}
```

## OrquestadorCubit Pattern

Patrón propio del proyecto para coordinar múltiples cubits en una pantalla:

```dart
// features/xxx/presentation/cubit/orquestador_xxx_state.dart
enum OrquestadorXxxEffect {
  navigateToPlayer,
  showErrorSnackbar,
  showSuccessMessage,
}

class OrquestadorXxxState extends Equatable {
  final OrquestadorXxxEffect? effect;
  final String? effectPayload;

  const OrquestadorXxxState({this.effect, this.effectPayload});

  OrquestadorXxxState copyWith({
    OrquestadorXxxEffect? effect,
    String? effectPayload,
  }) {
    return OrquestadorXxxState(
      effect: effect,
      effectPayload: effectPayload,
    );
  }

  @override
  List<Object?> get props => [effect, effectPayload];
}
```

```dart
// features/xxx/presentation/cubit/orquestador_xxx_cubit.dart
class OrquestadorXxxCubit extends Cubit<OrquestadorXxxState> {
  final XxxCubit _xxxCubit;
  final PlayerBlocBloc _playerBloc;

  OrquestadorXxxCubit({
    required XxxCubit xxxCubit,
    required PlayerBlocBloc playerBloc,
  })  : _xxxCubit = xxxCubit,
        _playerBloc = playerBloc,
        super(const OrquestadorXxxState());

  // Coordina acciones que afectan múltiples cubits
  void onSongTapped(NowPlayingData song) {
    _playerBloc.add(LoadTrackEvent(track: song));
    emit(state.copyWith(effect: OrquestadorXxxEffect.navigateToPlayer));
  }

  // Limpiar efecto después de consumirlo en la UI
  void clearEffect() {
    emit(const OrquestadorXxxState());
  }
}
```

### Uso del OrquestadorCubit en la pantalla
```dart
// En la pantalla, escuchar efectos con BlocListener
BlocListener<OrquestadorXxxCubit, OrquestadorXxxState>(
  listenWhen: (prev, curr) => curr.effect != null,
  listener: (context, state) {
    switch (state.effect) {
      case OrquestadorXxxEffect.navigateToPlayer:
        context.router.push(const PlayerRoute());
        context.read<OrquestadorXxxCubit>().clearEffect();
      case OrquestadorXxxEffect.showErrorSnackbar:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(state.effectPayload ?? 'Error')),
        );
        context.read<OrquestadorXxxCubit>().clearEffect();
      case null:
        break;
    }
  },
)
```

## PlayerBlocBloc (Singleton global)

El PlayerBlocBloc es **singleton** en toda la app. Se usa directamente en cualquier feature:

```dart
// Obtener desde GetIt
final playerBloc = getIt<PlayerBlocBloc>();

// Reproducir una canción
playerBloc.add(LoadTrackEvent(track: NowPlayingData.fromSong(song)));

// Reproducir playlist completa desde índice
playerBloc.add(LoadPlaylistEvent(
  playlist: tracks.map(NowPlayingData.fromPlaylistTrack).toList(),
  startIndex: 0,
));

// Controls
playerBloc.add(const PlayPauseToggleEvent());
playerBloc.add(const NextTrackEvent());
playerBloc.add(SeekEvent(position: Duration(seconds: 30)));
playerBloc.add(SetLoopModeEvent(loopMode: LoopMode.one));
playerBloc.add(const ToggleShuffleEvent());
```

## Mini-player en Dashboard

El DashboardShell provee el PlayerBlocBloc a todos los hijos via BlocProvider.
Para acceder desde cualquier widget hijo:

```dart
// Leer estado del player
BlocBuilder<PlayerBlocBloc, PlayerBlocState>(
  builder: (context, state) {
    if (state is! PlayerBlocState) return const SizedBox.shrink();
    final loaded = state;
    return MiniPlayer(
      track: loaded.currentTrack,
      isPlaying: loaded.isPlaying,
      onTap: () => context.router.push(const PlayerRoute()),
    );
  },
)
```

## Reglas críticas

1. **SIEMPRE** verificar `isClosed` antes y después de `await`
2. **SIEMPRE** usar `clearError: true` en `copyWith` al iniciar loading
3. **NUNCA** emitir desde `dispose()` o listeners externos sin check
4. **SIEMPRE** usar `BaseBlocMixin.getErrorMessage(error)` para mensajes de error
5. **REGISTRAR** cubits como `factory` en GetIt (nueva instancia por pantalla)
6. **REGISTRAR** PlayerBlocBloc como `lazySingleton` (compartido en toda la app)
