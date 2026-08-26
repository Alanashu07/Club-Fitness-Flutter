enum UserRole {
  admin('admin', 'Admin', 'Login as Admin'),
  trainer('trainer', 'Trainer', 'Login as Trainer'),
  user('user', 'User', 'Login as User');

  const UserRole(this.key, this.title, this.subtitle);
  final String key;
  final String title;
  final String subtitle;
}

class AppConstants {
  static const String appName = r"Club Fitness";
  static const String version = "1.0.0";
}
