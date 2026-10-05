part of '../routes_class.dart';

class MemberRoutes {
  static List<RouteBase> routes = [
    GoRoute(
      path: Routes.home,
      name: RoutesName.home,
      builder: (context, state) => const MemberHomeScreen(),
    ),
    GoRoute(
      path: Routes.renewMembership,
      name: RoutesName.renewMembership,
      builder: (context, state) => const RenewMembershipScreen(),
    ),
    GoRoute(
      path: Routes.profile,
      name: RoutesName.profile,
      builder: (context, state) => const ProfileScreen(),
    ),
    GoRoute(
      path: Routes.memberWorkout,
      name: RoutesName.memberWorkout,
      builder: (context, state) => const WorkoutPlanScreen(),
    ),
    GoRoute(
      path: "${Routes.memberDetails}/:id",
      name: RoutesName.memberDetails,
      builder: (context, state) {
        final id = state.pathParameters['id'];
        return MemberDetailProvider(memberId: id!);
      },
    ),
  ];
}
