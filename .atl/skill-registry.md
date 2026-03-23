# Skill Registry - music_app_flutter

> Generated: 2026-03-23 | Mode: engram

## Project Context

| Attribute | Value |
|-----------|-------|
| **Stack** | Flutter 3.10.1+ / Dart |
| **State Management** | flutter_bloc (Bloc/Cubit pattern) |
| **DI** | GetIt (service locator) |
| **Routing** | auto_route |
| **HTTP Client** | Dio |
| **Local DB** | Hive |
| **Audio** | just_audio + audio_service |
| **Testing** | flutter_test, mocktail, bloc_test, integration_test |
| **Linting** | flutter_lints (strict mode) |
| **Architecture** | Clean Architecture (feature-first) |

## Feature Structure Pattern

```
lib/
├── core/                    # Shared infrastructure
│   ├── app_injection/       # GetIt DI configuration
│   ├── app_router/          # auto_route configuration
│   ├── bloc/                # Base bloc mixins
│   ├── domain/              # Shared entities, mappers, repositories
│   ├── managers/            # Auth manager, token manager
│   ├── presentation/        # Shared widgets
│   ├── services/            # Auth, network, local storage
│   ├── theme/               # App theming
│   └── utils/               # Extensions, helpers
├── data/offline/            # Offline models and services (Hive)
└── features/                # Feature modules (Clean Architecture)
    └── {feature}/
        ├── data/            # Data sources, repositories impl
        │   ├── datasources/
        │   └── repositories/
        ├── domain/          # Entities, repositories, use cases
        │   ├── entities/
        │   ├── repositories/
        │   └── use_cases/
        └── presentation/    # Screens, cubits/blocs, widgets
            ├── cubit/ (or bloc/)
            ├── widgets/
            │   ├── atoms/   # Basic UI elements
            │   ├── molecules/
            │   └── organisms/
            └── {feature}_screen.dart
```

## Naming Conventions

| Element | Convention |
|---------|------------|
| Files | snake_case.dart |
| Classes | PascalCase |
| Variables | camelCase |
| Constants | camelCase |
| Entities | `{Name}Entity` or bare `{Name}` |
| Models | `{Name}Model` |
| Repositories | `{Name}Repository` (interface) / `{Name}RepositoryImpl` |
| Use Cases | `{Action}{Target}UseCase` |
| Cubits | `{Feature}Cubit` / `{Feature}State` |
| Blocs | `{Feature}Bloc` / `{Feature}Event` / `{Feature}State` |
| Screens | `{Feature}Screen` |
| Widgets | `{Description}Widget` |

## Available Skills

### SDD Phases (system)

| Skill | Path | Description |
|-------|------|-------------|
| sdd-init | `~/.config/opencode/skills/sdd-init/SKILL.md` | Initialize SDD context in project |
| sdd-explore | `~/.config/opencode/skills/sdd-explore/SKILL.md` | Explore ideas before committing |
| sdd-propose | `~/.config/opencode/skills/sdd-propose/SKILL.md` | Create change proposals |
| sdd-spec | `~/.config/opencode/skills/sdd-spec/SKILL.md` | Write specifications |
| sdd-design | `~/.config/opencode/skills/sdd-design/SKILL.md` | Create technical designs |
| sdd-tasks | `~/.config/opencode/skills/sdd-tasks/SKILL.md` | Break down into tasks |
| sdd-apply | `~/.config/opencode/skills/sdd-apply/SKILL.md` | Implement tasks |
| sdd-verify | `~/.config/opencode/skills/sdd-verify/SKILL.md` | Validate implementation |
| sdd-archive | `~/.config/opencode/skills/sdd-archive/SKILL.md` | Archive completed changes |

### General Skills

| Skill | Path | Description |
|-------|------|-------------|
| go-testing | `~/.config/opencode/skills/go-testing/SKILL.md` | Go testing patterns |
| skill-creator | `~/.config/opencode/skills/skill-creator/SKILL.md` | Create new AI agent skills |

## Project-Level Conventions

No project-level AGENTS.md, CLAUDE.md, or .cursorrules found.

## Linting Rules (Key)

- `prefer_const_constructors` - Use const constructors
- `prefer_final_locals` - Final local variables
- `prefer_single_quotes` - Single quotes for strings
- `avoid_dynamic_calls` - No dynamic calls
- `use_build_context_synchronously` - Warn on async context use
- `always_declare_return_types` - Explicit return types
- Strong mode with `implicit-casts: false` and `implicit-dynamic: false`

## Key Dependencies

| Category | Package | Version |
|----------|---------|---------|
| State | flutter_bloc | ^9.1.1 |
| DI | get_it | ^9.2.0 |
| Routing | auto_route | ^11.1.0 |
| HTTP | dio | ^5.9.0 |
| Audio | just_audio | ^0.10.5 |
| Audio Service | audio_service | ^0.18.12 |
| Local DB | hive | ^2.2.3 |
| Secure Storage | flutter_secure_storage | ^10.0.0 |
| Images | cached_network_image | ^3.4.1 |
| Shimmer | shimmer | ^3.0.0 |
| OAuth | google_sign_in, sign_in_with_apple | ^6.2.2, ^6.1.4 |
| Connectivity | connectivity_plus | ^6.1.4 |
| Testing | mocktail, bloc_test | ^1.0.4, ^10.0.0 |
