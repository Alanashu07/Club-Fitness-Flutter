import 'member_manager_entities.dart';

class MemberDetailEntity {
  final MemberEntity member;
  final List<AttendanceEntity> attendance;
  final List<FeeHistoryEntity> feeHistory;
  final List<OfferRedemptionEntity> offerRedemptions;

  const MemberDetailEntity({
    this.member = const MemberEntity(),
    this.attendance = const [],
    this.feeHistory = const [],
    this.offerRedemptions = const [],
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
