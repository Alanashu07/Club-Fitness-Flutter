enum Env {
  local('local'), dev('dev'), production('production');
  const Env(this.key);
  final String key;
  bool get isProduction => this == Env.production;

  static Env fromKey(String? key) {
    return values.firstWhere((e) => e.key == key?.toLowerCase(), orElse: () => local);
  }
}

class EndPoints {
  static bool get isProduction => false;
  static const String environment = String.fromEnvironment('ENV', defaultValue: 'local');

  static Env get env => Env.fromKey(environment);

  static String get baseUrl {
    switch (env) {
      case Env.local:
      case Env.dev:
        return 'http://192.168.29.50:3000';
      case Env.production:
        return 'https://api.clubfitness.co.in';
    }
  }

  static String get baseMediaUrl {
    switch (env) {
      case Env.local:
      case Env.dev:
        return 'http://localhost:3000';
      case Env.production:
        return 'https://api.clubfitness.co.in';
    }
  }
  static String appBaseUrl = '$baseUrl/app';
  static const String login = '/api/v1/auth/login';
  static const String register = '/api/v1/auth/register';
  static const String refresh = '/api/v1/auth/refresh';
  static const String rotate = '/api/v1/auth/rotate';
  static const String logout = '/api/v1/auth/logout';
  static const String logoutAll = '/api/v1/auth/logout-all';
  static const String myProfile = '/api/v1/auth/me';
  static const String googleLogin = '/api/v1/auth/google';
  static const String firebasePhoneLogin = '/api/v1/auth/firebase-phone-login';
  static const String emailRequestOtp = '/api/v1/auth/email/otp/request';
  static const String emailVerifyOtp = '/api/v1/auth/email/otp/verify';

  //============================================================================
  // HOME
  //============================================================================
  static const String home = '/api/v1/home';

  //============================================================================
  // MEMBERS
  //============================================================================
  static const String members = '/api/v1/members';
  static String memberDetails(String id) => '$members/$id';
  static const String trainers = '$members/trainers';
  static const String membershipPlans = '$members/membership-plans';
  static String updateOrDeleteMembershipPlan(String id) => "$membershipPlans/$id";
  static String reactivateMember(String id) => "$members/$id/reactivate";
  static String suspendMember(String id) => "$members/$id/suspend";
  static String renewMembership(String id) => "$members/$id/renew";
  static String revertLastRenewal(String id) => "$members/$id/renew/revert-last";

  //============================================================================
  // FEES
  //============================================================================
  static const String fees = '/api/v1/fees';
  static String feeDetails(String id) => '$fees/$id';
  static String feeActions(String id, FeeActions action) =>
      '$fees/$id/${action.key}';
  static const String feeSummary = '$fees/summary';
  static const String exportFeesPdf = '$fees/export/pdf';

  //============================================================================
  // WORKOUTS
  //============================================================================
  static const String workout = '/api/v1/workouts';
  static const String workoutTemplates = '$workout/templates';
  static String workoutTemplateDetails(String id) => '$workout/templates/$id';
  static const String exercises = '$workout/exercises';
  static String exerciseDetails(String id) => '$exercises/$id';
  static const String assignWorkout = '$workout/assign';
  static const String workoutPlans = '$workout/plans';
  static String workoutPlanDetails(String id) => '$workoutPlans/$id';

  //============================================================================
  // REPORTS
  //============================================================================
  static const String reports = '/api/v1/report';
  static const String salesReport = '$reports/sales';
  static const String exportSalesReportPdf = '$salesReport/export/pdf';
  static const String exportSalesReportExcel = '$salesReport/export/excel';

  //============================================================================
  // REPORTS
  //============================================================================
  static const String offers = '/api/v1/offers';
  static String offerDetails(String id) => '$offers/$id';
}

enum FeeActions {
  create('create'),
  update('update'),
  delete('delete'),
  approve('approve'),
  reject('reject'),
  markPaid('mark-paid'),
  waive('waive'),
  remind('remind'),
  export('export'),
  receipt('receipt');

  const FeeActions(this.key);
  final String key;
}
