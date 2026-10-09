import '../../domain/entities/member_detail_entity.dart';
import 'member_manager_models.dart';

class MemberDetailModel extends MemberDetailEntity {
  const MemberDetailModel({
    super.member,
    super.attendance,
    super.feeHistory,
    super.offerRedemptions,
  });

  factory MemberDetailModel.fromJson(Map<String, dynamic> json) {
    return MemberDetailModel(
      member: json['member'] != null ? MemberModel.fromJson(json['member']) : const MemberModel(),
      attendance: (json['attendance'] as List?)?.map((e) => AttendanceModel.fromJson(e)).toList() ?? const [],
      feeHistory: (json['feeHistory'] as List?)?.map((e) => FeeHistoryModel.fromJson(e)).toList() ?? const [],
      offerRedemptions: (json['offerRedemptions'] as List?)?.map((e) => OfferRedemptionModel.fromJson(e)).toList() ?? const [],
    );
  }

  factory MemberDetailModel.fromEntity(MemberDetailEntity entity) {
    return MemberDetailModel(
      member: entity.member,
      attendance: entity.attendance,
      feeHistory: entity.feeHistory,
      offerRedemptions: entity.offerRedemptions,
    );
  }

  MemberDetailModel copyWith({
    MemberModel? member,
    List<AttendanceModel>? attendance,
    List<FeeHistoryModel>? feeHistory,
    List<OfferRedemptionModel>? offerRedemptions,
  }) => MemberDetailModel(
      member: member ?? this.member,
      attendance: attendance ?? this.attendance,
      feeHistory: feeHistory ?? this.feeHistory,
      offerRedemptions: offerRedemptions ?? this.offerRedemptions
  );

  Map<String, dynamic> toJson() => {
        'member': MemberModel.fromEntity(member).toJson(),
        'attendance': attendance.map((e) => AttendanceModel.fromEntity(e).toJson()).toList(),
        'feeHistory': feeHistory.map((e) => FeeHistoryModel.fromEntity(e).toJson()).toList(),
        'offerRedemptions': offerRedemptions.map((e) => OfferRedemptionModel.fromEntity(e).toJson()).toList(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MemberDetailModel('
      'member: $member, '
      'attendance: $attendance, '
      'feeHistory: $feeHistory, '
    ')';
  }

// Helper function to remove empty or default values from JSON
bool _removeEmpty(dynamic value) {
  if (value == null) return true;
  if (value is num) return value == 0;
  if (value is String) return value.isEmpty;
  if (value is List) return value.isEmpty;
  if (value is bool) return !value;
  if (value is Map) {return (value..removeWhere((key, value) => _removeEmpty(value),)).isEmpty;}
  return false;
}
}

