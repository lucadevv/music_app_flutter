# Music App Development Guidelines

## Project Overview
This is a Flutter music streaming app built with Clean Architecture, BLoC state management, and feature-first organization. All agents working on this codebase should follow these guidelines strictly.

## Development Commands

### Essential Commands
```bash
# Install dependencies
flutter pub get

# Generate code (auto_route)
flutter packages pub run build_runner build

# Run the app
flutter run

# Build for release
flutter build apk --release
flutter build ios --release
```

### Code Quality
```bash
# Static analysis
flutter analyze

# Format code
dart format .

# Run tests
flutter test

# Run single test file
flutter test test/widget_test.dart

# Run tests with coverage
flutter test --coverage
```

## Architecture Guidelines

### Clean Architecture Structure
```
lib/
├── core/                 # Shared infrastructure (DI, routing, utils)
├── features/            # Feature modules
│   └── feature_name/
│       ├── data/        # Data sources, models, repository implementations
│       ├── domain/      # Entities, repositories (contracts), use cases
│       └── presentation/ # UI, cubits, widgets
└── main.dart           # App entry point
```

### Feature Organization
- Each feature is completely self-contained
- Use BLoC/Cubit for state management in presentation layer
- Use cases orchestrate business logic in domain layer
- Repository pattern for data abstraction
- Dependency injection via GetIt

## Code Style Guidelines

### Imports
```dart
// 1. Dart core imports
import 'dart:async';

// 2. Flutter imports
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// 3. Package imports (alphabetical)
import 'package:dartz/dartz.dart';
import 'package:get_it/get_it.dart';

// 4. Project imports (relative, organized by feature)
import 'package:music_app/core/utils/app_exception.dart';
import 'package:music_app/features/home/domain/entities/home_response.dart';
import 'package:music_app/features/home/presentation/cubit/home_cubit.dart';
```

### Naming Conventions
- **Files**: snake_case (e.g., `home_cubit.dart`, `player_screen.dart`)
- **Classes**: PascalCase (e.g., `HomeCubit`, `PlayerScreen`)
- **Variables/Methods**: camelCase (e.g., `loadHome()`, `errorMessage`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`)
- **Private members**: prefix with `_` (e.g., `_repository`)

### BLoC/Cubit Pattern
```dart
class FeatureCubit extends Cubit<FeatureState> with BaseBlocMixin {
  final FeatureUseCase _useCase;
  
  FeatureCubit(this._useCase) : super(const FeatureState.initial());
  
  Future<void> fetchData() async {
    emit(state.copyWith(status: FeatureStatus.loading));
    
    final result = await _useCase();
    
    result.fold(
      (error) => emit(state.copyWith(
        status: FeatureStatus.failure,
        errorMessage: getErrorMessage(error),
      )),
      (data) => emit(state.copyWith(
        status: FeatureStatus.success,
        data: data,
      )),
    );
  }
}
```

### State Management
- Use `copyWith` for immutable state updates
- Include `clearError: true` when resetting errors
- Always check `isClosed` before emitting after async operations
- Use sealed classes/enums for status types

### Error Handling
```dart
// Use Either pattern from dartz
Future<Either<AppException, Data>> getData() async {
  try {
    final data = await dataSource.getData();
    return Right(data);
  } catch (e) {
    return Left(AppException.unknown(e.toString()));
  }
}

// In cubits - use BaseBlocMixin
result.fold(
  (error) => emit(state.copyWith(
    status: Status.failure,
    errorMessage: getErrorMessage(error),
  )),
  (data) => emit(state.copyWith(
    status: Status.success,
    data: data,
  )),
);
```

### Dependency Injection
```dart
// In AppInjection
Future<void> registerDependencies() async {
  // Singletons for shared services
  getIt.registerSingleton<Dio>(Dio());
  getIt.registerLazySingleton(() => AuthManager());
  
  // Factory for state management
  getIt.registerFactory<HomeCubit>(() => HomeCubit(getIt()));
  
  // Register use cases
  getIt.registerFactory<GetHomeUseCase>(() => GetHomeUseCase(getIt()));
}
```

### Widget Guidelines
- Use `const` constructors whenever possible
- Prefer `SizedBox` over `Container` for pure spacing
- Use `Expanded`/`Flexible` in `Row`/`Column` for responsive layouts
- Implement proper loading and error states
- Use `CachedNetworkImage` for remote images

### Navigation
- Use auto_route for type-safe navigation
- Prefer shell navigation for tab-based layouts
- Use `router.replaceAll()` for root navigation changes
- Implement route guards for authentication

### Testing
- Write unit tests for use cases and cubits
- Test widget functionality with `flutter_test`
- Mock external dependencies with `mockito`
- Test both success and error paths

### Audio Features
- Use `just_audio` for core playback functionality
- Implement `audio_service` for background playback
- Handle audio focus properly
- Manage player state globally via PlayerBloc

## File Organization

### Feature Structure Example
```
features/
└── home/
    ├── data/
    │   ├── data_sources/
    │   │   └── home_remote_data_source.dart
    │   ├── models/
    │   └── repositories/
    │       └── home_repository_impl.dart
    ├── domain/
    │   ├── entities/
    │   │   ├── home_response.dart
    │   │   └── home_section.dart
    │   ├── repositories/
    │   │   └── home_repository.dart
    │   └── use_cases/
    │       └── get_home_use_case.dart
    └── presentation/
        ├── cubit/
        │   ├── home_cubit.dart
        │   └── home_state.dart
        ├── screens/
        │   └── home_screen.dart
        └── widgets/
            └── home_section_widget.dart
```

## Key Dependencies
- `flutter_bloc`: State management
- `auto_route`: Type-safe navigation
- `dio`: HTTP client
- `get_it`: Dependency injection
- `just_audio`: Audio playback
- `audio_service`: Background audio
- `dartz`: Functional programming (Either)
- `equatable`: Value equality
- `cached_network_image`: Image caching

## Code Review Checklist
- [ ] Follows Clean Architecture principles
- [ ] Proper error handling with Either pattern
- [ ] Immutable states with copyWith
- [ ] Dependency injection properly set up
- [ ] Tests cover success and error cases
- [ ] Code passes `flutter analyze`
- [ ] Proper documentation for complex logic
- [ ] No hard-coded strings or values
- [ ] Responsive design considerations