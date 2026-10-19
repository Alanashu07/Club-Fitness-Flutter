part of '../routes_class.dart';

class AuthRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: Routes.login,
      name: RoutesName.login,
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: Routes.deleteAccount,
      name: RoutesName.deleteAccount,
      builder: (context, state) => const AccountDeletionScreen(),
    ),
  ];
}
