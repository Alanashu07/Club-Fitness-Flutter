enum MemberStatus {
  active('ACTIVE', 'Active'),
  suspended('SUSPENDED', 'Suspended'),
  expired('EXPIRED', 'Expired'),
  trial('TRIAL', 'Trial');

  const MemberStatus(this.key, this.label);
  final String key;
  final String label;
  String get lower => key.toLowerCase();
  String get upper => key.toUpperCase();

  static MemberStatus fromKey(String key) {
    return values.firstWhere(
      (e) => e.lower == key.toLowerCase(),
      orElse: () => MemberStatus.expired,
    );
  }
}
