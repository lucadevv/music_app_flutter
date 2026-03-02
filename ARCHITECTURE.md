# Arquitectura del Proyecto - Music App

## Visión General

Este documento describe la arquitectura del proyecto Flutter Music App, incluyendo principios, estructura y decisiones arquitectónicas.

---

## Principios Arquitectónicos

### 1. Clean Architecture

La aplicación sigue los principios de Clean Architecture con las siguientes capas:

```
Presentation (UI) → Domain (Business Logic) → Data (Repositories & Data Sources)
```

- **Domain**: Entidades, casos de uso, interfaces de repositorios (sin dependencias externas)
- **Data**: Implementaciones de repositorios, fuentes de datos, modelos
- **Presentation**: Widgets, Screens, Cubits/BLoCs

### 2. Feature-First Organization

Las features son el eje central de la organización:

```
features/
├── auth/
│   ├── data/
│   ├── domain/
│   └── presentation/
├── home/
├── player/
└── ...
```

### 3. Dependency Injection con GetIt

使用 GetIt para inyección de dependencias:

```dart
// Registro de singletons
getIt.registerSingleton<ApiServices>(ApiServices());

// Registro de factories (nueva instancia cada vez)
getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt()));
```

### 4. State Management con BLoC/Cubit

使用 flutter_bloc con el patrón Cubit:

```dart
class HomeCubit extends Cubit<HomeState> {
  final GetHomeUseCase _getHomeUseCase;
  
  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading));
    // ...
  }
}
```

---

## Estructura del Proyecto

```
lib/
├── core/
│   ├── domain/
│   │   ├── entities/          # Entidades compartidas (Song, etc.)
│   │   ├── repositories/       # Interfaces de repositorios
│   │   └── mappers/           # Mappers entre entidades
│   ├── presentation/
│   │   └── widgets/          # Widgets compartidos
│   ├── app_injection/         # Configuración de DI
│   ├── app_router/            # Navegación (auto_route)
│   ├── bloc/                  # BLoCs base
│   ├── services/              # Servicios core
│   ├── theme/                 # Temas
│   └── utils/                 # Utilidades
├── features/
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/
│   │   │   ├── models/
│   │   │   └── repositories/
│   │   ├── domain/
│   │   │   ├── entities/
│   │   │   ├── repositories/
│   │   │   └── usecases/
│   │   └── presentation/
│   │       ├── bloc/
│   │       ├── pages/
│   │       └── widgets/
│   ├── home/
│   ├── player/
│   └── ...
├── l10n/                     # Localización
└── main.dart
```

---

## Convenciones de Código

### Naming

| Tipo | Convención | Ejemplo |
|------|------------|---------|
| Archivos | snake_case | `home_cubit.dart` |
| Clases | PascalCase | `HomeCubit` |
| Métodos | camelCase | `loadHome()` |
| Constantes | UPPER_SNAKE_CASE | `API_BASE_URL` |
| Privados | `_prefix | `_repository` |

### Imports

```dart
// 1. Dart core
import 'dart:async';

// 2. Flutter
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 3. Paquetes externos (alfabético)
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

// 4. Proyecto
import 'package:music_app/core/app_router/app_routes.dart';
import 'package:music_app/features/home/domain/entities/home_response.dart';
```

### Patrón de Estado con Cubit

```dart
// Estado con enum de status
enum HomeStatus { initial, loading, success, failure }

class HomeState extends Equatable {
  final HomeStatus status;
  final HomeResponse? data;
  final String? errorMessage;
  
  const HomeState({this.status = HomeStatus.initial, this.data, this.errorMessage});
  
  HomeState copyWith({
    HomeStatus? status,
    HomeResponse? data,
    String? errorMessage,
    bool clearError = false,
  }) => HomeState(
    status: status ?? this.status,
    data: data ?? this.data,
    errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
  );
}

// Cubit con BaseBlocMixin
class HomeCubit extends Cubit<HomeState> with BaseBlocMixin {
  final GetHomeUseCase _useCase;
  
  HomeCubit(this._useCase) : super(const HomeState());
  
  Future<void> loadHome() async {
    emit(state.copyWith(status: HomeStatus.loading, clearError: true));
    
    final result = await _useCase();
    
    result.fold(
      (error) => emit(state.copyWith(
        status: HomeStatus.failure,
        errorMessage: getErrorMessage(error),
      )),
      (data) => emit(state.copyWith(
        status: HomeStatus.success,
        data: data,
      )),
    );
  }
}
```

---

## Decisiones Arquitectónicas (ADRs)

### ADR-001: Arquitectura Híbrida Feature-First + Clean Architecture

**Contexto**: El proyecto empezó con una estructura híbrida donde algunas features tienen data/domain/presentation y otras no.

**Decisión**: Mantener la estructura híbrida pero establecer como objetivo que todas las features sigan el patrón completo. Las nuevas features DEBEN seguir la estructura completa.

**Estado**: Aprobado

---

### ADR-002: Centralización de Entidades de Dominio

**Contexto**: Existían múltiples entidades Song duplicadas en diferentes features (Song, ChartSong, DownloadedSong, RecentlyPlayedSong, etc.)

**Decisión**: Crear una entidad Song centralizada en `core/domain/entities/song.dart` y usar mappers para convertir desde las entidades específicas de cada feature.

**Estado**: Aprobado

---

### ADR-003: Widgets Compartidos en Core

**Contexto**: SongListItemWidget estaba duplicado en home y library, cuando ya existía en core/widgets.

**Decisión**: Centralizar todos los widgets reutilizables en `core/presentation/widgets/` y actualizar las features para usar los widgets compartidos.

**Estado**: Aprobado

---

### ADR-004: Mantener BLoC/Cubit sobre Riverpod

**Contexto**: Riverpod es recomendado actualmente para nuevos proyectos, pero el equipo ya tiene experiencia con BLoC/Cubit.

**Decisión**: Mantener BLoC/Cubit para el código existente. Las nuevas features pueden usar BLoC/Cubit. No hay migración planificada a Riverpod.

**Estado**: Aprobado

---

### ADR-005: Eliminación de God Files

**Contexto**: library_service.dart contenía 641 líneas con 14+ clases.

**Decisión**: Dividir el god file en las capas apropiadas (data/models, domain/usecases, presentation).

**Estado**: Aprobado

---

## Estado de Features

| Feature | data/ | domain/ | presentation/ | Estado |
|---------|-------|---------|--------------|--------|
| album | ✅ | ✅ | ✅ | Completo |
| artist | ✅ | ✅ | ✅ | Completo |
| auth | ✅ | ✅ | ✅ | Completo |
| downloads | ✅ | ✅ | ✅ | Completo |
| home | ✅ | ✅ | ✅ | Completo |
| mood_genre | ✅ | ✅ | ✅ | Completo |
| playlist | ✅ | ✅ | ✅ | Completo |
| search | ✅ | ✅ | ✅ | Completo |
| profile | Parcial | ❌ | ✅ | En progreso |
| library | ❌ | ❌ | ✅ | Pendiente |
| player | ❌ | ✅ | ✅ | Parcial |
| dashboard | ❌ | ❌ | ✅ | Pendiente |
| favorites | ❌ | ❌ | ✅ | Pendiente |
| recently_played | ❌ | ✅ | ✅ | Parcial |
| user_playlists | ❌ | ❌ | ✅ | Pendiente |
| queue | ❌ | ❌ | ✅ | Pendiente |
| offline | ❌ | ❌ | ✅ | Pendiente |
| onboarding | ❌ | ❌ | ✅ | Pendiente |
| relax | ❌ | ❌ | ✅ | Pendiente |
| song_options | ❌ | ❌ | ✅ | Pendiente |
| splash | ❌ | ❌ | ✅ | Pendiente |
| liked | ❌ | ❌ | ✅ | Pendiente |

---

## Próximos Pasos

1. ~~Centralizar entidad Song~~ ✅ Completado
2. ~~Crear SongRepository interfaz~~ ✅ Completado  
3. ~~Unificar SongListItemWidget~~ ✅ Completado
4. ~~Dividir library_service.dart~~ ✅ Completado
5. ~~Reorganizar archivos de profile~~ ✅ Completado
6. Migrar gradualmente features incompletas a estructura CA
7. Implementar SongRepository
8. Agregar tests unitarios para domain layer

---

## Referencias

- [Flutter Clean Architecture - Andrea](https://codewithandrea.com/articles/flutter-project-structure/)
- [BLoC Pattern Documentation](https://bloclibrary.dev)
- [GetIt Documentation](https://github.com/fluttercommunity/get_it)
