class EndPoints {
  static bool get isProduction => false;

  ///Build for production with `flutter build appbundle --dart-define=BASE_URL=https://www.club_fitness.com`
  static const String baseUrl = String.fromEnvironment(
    'BASE_URL',
    defaultValue: 'http://192.168.29.50:3000',
  );
  static const String appBaseUrl = '$baseUrl/app';
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
  static const String trainers = '$members/trainers';
  static const String membershipPlans = '$members/membership-plans';

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
}

enum FeeActions {
  approve('approve'),
  reject('reject'),
  markPaid('mark-paid'),
  waive('waive'),
  remind('remind'),
  receipt('receipt');

  const FeeActions(this.key);
  final String key;
}
