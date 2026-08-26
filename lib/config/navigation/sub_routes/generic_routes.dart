part of '../routes_class.dart';

class GenericRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: Routes.initial,
      name: RoutesName.initial,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: Routes.roleSelect,
      name: RoutesName.roleSelect,
      builder: (context, state) => const RoleSelectScreen(),
    ),
    GoRoute(
      path: Routes.shopHome,
      name: RoutesName.shopHome,
      builder: (context, state) => const ShopHomeScreen(),
    ),
    GoRoute(
      path: Routes.notifications,
      name: RoutesName.notifications,
      builder: (context, state) => const NotificationsScreen(),
    ),
  ];
}
