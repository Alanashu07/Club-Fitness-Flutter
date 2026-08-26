part of '../routes_class.dart';

class AuthRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: Routes.login,
      name: RoutesName.login,
      builder: (context, state) => const LoginScreen(),
    ),
  ];
}
