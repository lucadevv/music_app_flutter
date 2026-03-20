# music_app

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Testing

Run unit + widget tests:

```bash
fvm flutter test
```

Run the deterministic player widget tests only:

```bash
fvm flutter test test/widget/player_widgets_test.dart
```

Run the player E2E harness (integration_test) on a device/simulator:

```bash
fvm flutter test integration_test/player_flows_test.dart
```

