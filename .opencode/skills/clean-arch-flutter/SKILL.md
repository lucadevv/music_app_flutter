---
name: clean-arch-flutter
description: Clean Architecture para Flutter en este proyecto de música. Guías de capas, contratos, inyección de dependencias con GetIt, registro en AppInjection. Usar cuando crees o modifiques la arquitectura de una feature.
---

# Clean Architecture - Music App Flutter

## Estructura de una feature completa

```
lib/features/{feature_name}/
├── data/
│   ├── data_sources/
│   │   └── {feature}_remote_data_source.dart   ← abstract + impl
│   ├── models/
│   │   └── {feature}_model.dart                ← extiende entidad, fromJson
│   ├── repositories/
│   │   └── {feature}_repository_impl.dart      ← implementa contrato
│   └── isolates/                               ← (opcional) para JSON pesado
│       └── {feature}_parsing_isolate.dart
├── domain/
│   ├── entities/
│   │   └── {feature}_entity.dart               ← clase inmutable, Dart puro
│   ├── repositories/
│   │   └── {feature}_repository.dart           ← contrato abstracto
│   └── use_cases/
│       └── get_{feature}_use_case.dart         ← un método call()
└── presentation/
    ├── cubit/
    │   ├── {feature}_cubit.dart
    │   ├── {feature}_state.dart
    │   ├── orquestador_{feature}_cubit.dart     ← (si se necesita)
    │   ├── orquestador_{feature}_state.dart
    │   └── orquestador_{feature}_effect.dart
    ├── screens/
    │   └── {feature}_screen.dart               ← @RoutePage()
    └── widgets/
        └── {feature}_widget.dart
```

## Reglas de dependencias entre capas

```
presentation → domain (sí)
data         → domain (sí)
domain       → NADA de presentation ni data (nunca)
```

**Imports permitidos:**
- `presentation/` puede importar `domain/entities/`, `domain/repositories/`
- `data/` puede importar `domain/entities/`, `domain/repositories/`
- `domain/` solo puede importar Dart puro + `core/utils/`

## Entidades (Domain)

Inmutables, sin lógica de serialización, solo Dart puro:

```dart
// lib/features/xxx/domain/entities/xxx_entity.dart
class XxxEntity {
  final String id;
  final String title;
  final List<SearchArtist> artists;  // puede referenciar otras entidades domain
  final String? streamUrl;

  const XxxEntity({
    required this.id,
    required this.title,
    required this.artists,
    this.streamUrl,
  });
}
```

## Modelos (Data)

Extienden entidades, añaden serialización:

```dart
// lib/features/xxx/data/models/xxx_model.dart
import '../../domain/entities/xxx_entity.dart';

class XxxModel extends XxxEntity {
  const XxxModel({
    required super.id,
    required super.title,
    required super.artists,
    super.streamUrl,
  });

  factory XxxModel.fromJson(Map<String, dynamic> json) {
    return XxxModel(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      artists: (json['artists'] as List<dynamic>?)
          ?.map((e) => SearchArtistModel.fromJson(e as Map<String, dynamic>))
          .toList() ?? [],
      streamUrl: json['stream_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'stream_url': streamUrl,
  };
}
```

## Repositorios

### Contrato (Domain)
```dart
// lib/features/xxx/domain/repositories/xxx_repository.dart
import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/xxx_entity.dart';

abstract class XxxRepository {
  Future<Either<AppException, XxxEntity>> getXxx(String id);
  Future<Either<AppException, List<XxxEntity>>> getXxxList();
}
```

### Implementación (Data)
```dart
// lib/features/xxx/data/repositories/xxx_repository_impl.dart
import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../../domain/entities/xxx_entity.dart';
import '../../domain/repositories/xxx_repository.dart';
import '../data_sources/xxx_remote_data_source.dart';

class XxxRepositoryImpl implements XxxRepository {
  final XxxRemoteDataSource _dataSource;

  XxxRepositoryImpl(this._dataSource);

  @override
  Future<Either<AppException, XxxEntity>> getXxx(String id) async {
    return await _dataSource.getXxx(id);
  }
}
```

## Use Cases

Un use case = una responsabilidad = método `call()`:

```dart
// lib/features/xxx/domain/use_cases/get_xxx_use_case.dart
import 'package:dartz/dartz.dart';
import 'package:music_app/core/utils/exeptions/app_exceptions.dart';
import '../entities/xxx_entity.dart';
import '../repositories/xxx_repository.dart';

class GetXxxUseCase {
  final XxxRepository _repository;

  GetXxxUseCase(this._repository);

  Future<Either<AppException, XxxEntity>> call(String id) {
    return _repository.getXxx(id);
  }
}

// Use case sin parámetros:
class GetXxxListUseCase {
  final XxxRepository _repository;
  GetXxxListUseCase(this._repository);
  Future<Either<AppException, List<XxxEntity>>> call() => _repository.getXxxList();
}
```

## Registro en AppInjection

Siempre en este orden dentro de `_registerXxxFeature()`:

```dart
void _registerXxxFeature() {
  // 1. Data Source
  if (!_getIt.isRegistered<XxxRemoteDataSource>()) {
    _getIt.registerLazySingleton<XxxRemoteDataSource>(
      () => XxxRemoteDataSourceImpl(_getIt<ApiServices>()),
    );
  }

  // 2. Repository
  if (!_getIt.isRegistered<XxxRepository>()) {
    _getIt.registerLazySingleton<XxxRepository>(
      () => XxxRepositoryImpl(_getIt<XxxRemoteDataSource>()),
    );
  }

  // 3. Use Cases
  if (!_getIt.isRegistered<GetXxxUseCase>()) {
    _getIt.registerLazySingleton<GetXxxUseCase>(
      () => GetXxxUseCase(_getIt<XxxRepository>()),
    );
  }

  // 4. Cubits (FACTORY, no singleton)
  if (!_getIt.isRegistered<XxxCubit>()) {
    _getIt.registerFactory<XxxCubit>(
      () => XxxCubit(_getIt<GetXxxUseCase>()),
    );
  }
}
```

Y llamar en `_init()`:
```dart
_registerXxxFeature();
```

## Endpoints API de este proyecto

| Recurso | Endpoint | Parámetros |
|---------|----------|-----------|
| Home/Explore | `GET /music/explore` | `include_stream_urls=true` |
| Búsqueda | `GET /music/search` | `q=`, `filter=`, `include_stream_urls=true` |
| Playlist | `GET /music/playlists/{id}` | `include_stream_urls=true` |
| Mood/Genre | `GET /music/explore/moods/{params}` | `include_stream_urls=true` |
| Búsquedas recientes | `GET /music/recent-searches` | `limit=10`, `include_stream_urls=true` |
| Login | `POST /auth/login` | `{email, password}` |
| Register | `POST /auth/register` | `{email, password, firstName, lastName}` |
| Refresh | `POST /auth/refresh` | `{refreshToken}` |

**IMPORTANTE**: Siempre incluir `include_stream_urls=true` en endpoints de música para obtener URLs de streaming directas.

## Isolates para JSON pesado

Para playlists grandes, usar isolates (como `PlaylistResponseParsingIsolate`):

```dart
// lib/features/xxx/data/isolates/xxx_parsing_isolate.dart
import 'package:flutter/foundation.dart';

class XxxParsingIsolate {
  static Future<XxxEntity> parseInIsolate(Map<String, dynamic> json) async {
    return await compute(_parseXxx, json);
  }

  static XxxEntity _parseXxx(Map<String, dynamic> json) {
    return XxxModel.fromJson(json);
  }
}
```
