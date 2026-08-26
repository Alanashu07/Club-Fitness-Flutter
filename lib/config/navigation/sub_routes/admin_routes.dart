part of '../routes_class.dart';

class AdminRoutes {
  static final List<RouteBase> routes = [
    GoRoute(
      path: Routes.adminHome,
      name: RoutesName.adminHome,
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: Routes.addMember,
      name: RoutesName.addMember,
      builder: (context, state) => const AdminMembersScreen(),
    ),
    GoRoute(
      path: Routes.assignWorkout,
      name: RoutesName.assignWorkout,
      builder: (context, state) => const AssignWorkoutProvider(),
    ),
    GoRoute(
      path: Routes.announcementCreate,
      name: RoutesName.announcementCreate,
      builder: (context, state) => const AnnouncementCreateScreen(),
    ),
    GoRoute(
      path: Routes.adminReports,
      name: RoutesName.adminReports,
      builder: (context, state) => const ReportsProvider(),
    ),
    GoRoute(
      path: Routes.manageFees,
      name: RoutesName.manageFees,
      builder: (context, state) => const FeesManagementProvider(),
    ),
    GoRoute(
      path: Routes.feeDetails(':id'),
      name: RoutesName.feeDetails,
      builder: (context, state) {
        final extra = state.extra as Map;
        return FeeDetailScreen(record: extra['fee']);
      },
    ),
    GoRoute(
      path: Routes.shopAdminHome,
      name: RoutesName.shopAdminHome,
      builder: (context, state) => const ShopAdminScreen(),
    ),
    GoRoute(
      path: Routes.adminProfile,
      name: RoutesName.adminProfile,
      builder: (context, state) => const AdminProfileScreen(),
    ),
    GoRoute(
      path: Routes.membershipPlans,
      name: RoutesName.membershipPlans,
      builder: (context, state) => const MembershipPlansScreen(),
    ),
  ];
}
