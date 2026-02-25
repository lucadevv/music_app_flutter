import 'package:auto_route/auto_route.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';

class PublicRoutes {
  static List<AutoRoute> routes() => [
    AutoRoute(path: '/', page: OnboardingRoute.page, initial: true),
    AutoRoute(path: '/social-login', page: SocialLoginRoute.page),
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(path: '/forgot-password', page: ForgotPasswordRoute.page),
  ];
}
