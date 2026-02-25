import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:music_app/app.dart';
import 'package:music_app/core/app_injection/app_injection.dart';
import 'package:music_app/core/config/app_config.dart';

final GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AppInjection(
    getIt: getIt,
    baseUrl: AppConfig.baseUrl,
    accessToken: AppConfig.accessToken,
  );
  // Esperar a que SharedPreferences y dependencias estén listas
  await getIt.allReady();
  runApp(const App());
}
