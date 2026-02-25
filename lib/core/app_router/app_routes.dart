import 'package:auto_route/auto_route.dart';
import 'package:music_app/core/app_router/private_routes.dart';
import 'package:music_app/core/app_router/public_routes.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => [
    ...PublicRoutes.routes(),
    ...PrivateRoutes.routes(),
  ];
}
