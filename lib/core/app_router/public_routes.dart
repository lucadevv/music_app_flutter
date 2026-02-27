import 'package:auto_route/auto_route.dart';
import 'package:music_app/core/app_router/app_routes.gr.dart';
import 'package:music_app/core/app_router/guards/initial_route_guard.dart';

class PublicRoutes {
  static List<AutoRoute> routes() => [
    // Splash es la ruta inicial con el guard que decide a dónde navegar
    AutoRoute(
      path: '/',
      page: SplashRoute.page,
      initial: true,
      guards: [InitialRouteGuard()],
    ),
    AutoRoute(path: '/onboarding', page: OnboardingRoute.page),
    AutoRoute(path: '/social-login', page: SocialLoginRoute.page),
    AutoRoute(path: '/login', page: LoginRoute.page),
    AutoRoute(path: '/register', page: RegisterRoute.page),
    AutoRoute(path: '/forgot-password', page: ForgotPasswordRoute.page),
  ];
}
