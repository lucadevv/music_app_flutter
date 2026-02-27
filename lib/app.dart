import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:music_app/core/app_router/app_routes.dart';
import 'package:music_app/core/theme/app_theme.dart';
import 'package:music_app/core/theme/theme_cubit.dart';
import 'package:music_app/main.dart';

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _router = getIt<AppRouter>();
  ThemeCubit? _themeCubit;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initApp();
  }

  @override
  void dispose() {
    _themeCubit?.close();
    super.dispose();
  }

  Future<void> _initApp() async {
    try {
      _themeCubit = await getIt.getAsync<ThemeCubit>();
      debugPrint('App._initApp: App inicializada correctamente');
    } catch (e) {
      debugPrint('App._initApp: Error inicializando app: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _themeCubit == null) {
      return MaterialApp(
        title: 'Music App',
        theme: AppTheme.dark(),
        home: const Scaffold(
          body: Center(
            child: const CircularProgressIndicator(),
          ),
        ),
        debugShowCheckedModeBanner: false,
      );
    }

    return BlocProvider.value(
      value: _themeCubit!,
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, themeState) {
          return MaterialApp.router(
            title: 'Music App',
            theme: AppTheme.light(),
            darkTheme: AppTheme.dark(),
            themeMode: themeState.themeMode,
            routerConfig: _router.config(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}
