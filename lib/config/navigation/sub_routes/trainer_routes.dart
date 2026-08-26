part of '../routes_class.dart';

class TrainerRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: Routes.trainerHome,
      name: RoutesName.trainerHome,
      builder: (context, state) => const TrainerHomeScreen(),
    )
  ];
}
