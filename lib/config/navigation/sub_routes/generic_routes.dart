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
    GoRoute(
      path: Routes.imageViewer,
      name: RoutesName.imageViewer,
      builder: (context, state) {
        final extra = state.extra as Map? ?? {};
        return ImageViewer(
          caption: extra['caption'],
          captions: extra['captions'],
          image: extra['image'],
          images: extra['images'],
          initialIndex: extra['index'] ?? 0,
          title: extra['title'],
          isNetwork: extra['is_network'] ?? true,
          tags: extra['tags'],
        );
      },
    ),
  ];
}
