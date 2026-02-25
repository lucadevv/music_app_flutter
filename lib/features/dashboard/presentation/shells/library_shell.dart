import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

@RoutePage()
class LibraryShell extends StatelessWidget {
  const LibraryShell({super.key});

  @override
  Widget build(BuildContext context) {
    return const AutoRouter();
  }
}
