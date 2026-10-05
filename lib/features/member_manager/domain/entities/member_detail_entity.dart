import 'member_manager_entities.dart';

class MemberDetailEntity {
  final MemberEntity member;
  final List<AttendanceEntity> attendance;
  final List<FeeHistoryEntity> feeHistory;

  const MemberDetailEntity({
    this.member = const MemberEntity(),
    this.attendance = const [],
    this.feeHistory = const [],
  });

  @override
  String toString() {
    return 'MemberDetailEntity('
      'member: $member, '
      'attendance: $attendance, '
      'feeHistory: $feeHistory, '
    ')';
  }
}
