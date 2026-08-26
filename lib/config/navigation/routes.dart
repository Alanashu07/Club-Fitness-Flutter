part of 'routes_class.dart';

class Routes {
  static const String initial = '/';
  static const String roleSelect = '/auth/role-select';
  static const String login = '/auth/login';

  //====================================================================================
  // HOME SCREEN
  //====================================================================================
  static const String home = '/home/user';
  static const String adminHome = '/home/admin';
  static const String trainerHome = '/home/trainer';

  //====================================================================================
  // MEMBER MANAGEMENT SCREEN
  //====================================================================================
  static const String addMember = '/admin/add-member';
  static const String renewMembership = '/renew-membership';
  static const String profile = '/profile';

  //====================================================================================
  // WORKOUT MANAGEMENT SCREEN
  //====================================================================================
  static const String assignWorkout = '/assign-workout/trainer-or-admin';
  static const String memberWorkout = '/workout/member';

  //====================================================================================
  // ADMIN UTILITIES SCREEN
  //====================================================================================
  static const String announcementCreate = '/announcement/create';
  static const String adminReports = '/admin/reports';
  static const String manageFees = '/admin/manage-fees';
  static String feeDetails(String id) => '/admin/manage-fees/details/$id';
  static const String adminProfile = '/profile/admin';

  //====================================================================================
  // SHOP SCREENS
  //====================================================================================
  static const String shopHome = "/shop/home";
  static const String shopAdminHome = "/shop/admin/home";
  
  //====================================================================================
  // NOTIFICATIONS
  //====================================================================================
  static const String notifications = '/notifications';

  //====================================================================================
  // MEMBERSHIP PLANS
  //====================================================================================
  static const String membershipPlans = '/membership-plans';
}

class RoutesName {
  static const String initial = 'initial';
  static const String roleSelect = 'role-select';
  static const String login = 'login';

  //====================================================================================
  // HOME SCREEN
  //====================================================================================
  static const String home = 'home';
  static const String adminHome = 'admin-home';
  static const String trainerHome = 'trainer-home';

  //====================================================================================
  // MEMBER MANAGEMENT SCREEN
  //====================================================================================
  static const String addMember = 'add-member';
  static const String renewMembership = 'renew-membership';
  static const String profile = 'profile';

  //====================================================================================
  // WORKOUT MANAGEMENT SCREEN
  //====================================================================================
  static const String assignWorkout = 'assign-workout';
  static const String memberWorkout = 'member-workout';

  //====================================================================================
  // ADMIN UTILITIES SCREEN
  //====================================================================================
  static const String announcementCreate = 'announcement-create';
  static const String adminReports = 'admin-reports';
  static const String manageFees = 'manage-fees';
  static const String feeDetails = 'fee-details';
  static const String adminProfile = 'admin-profile';

  //====================================================================================
  // SHOP SCREENS
  //====================================================================================
  static const String shopHome = "shop-home";
  static const String shopAdminHome = "shop-admin-home";

  //====================================================================================
  // NOTIFICATIONS
  //====================================================================================
  static const String notifications = 'notifications';

  //====================================================================================
  // MEMBERSHIP PLANS
  //====================================================================================
  static const String membershipPlans = 'membership-plans';
}
