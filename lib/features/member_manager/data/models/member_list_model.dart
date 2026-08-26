
import '../../domain/entities/member_list_entity.dart';

class MemberListModel extends MemberListEntity {
  const MemberListModel({
    super.id,
    super.name,
    super.phone,
    super.email,
    super.plan,
    super.planId,
    super.status,
    super.joinDate,
    super.expiryDate,
    super.daysLeft,
    super.trainer,
    super.trainerId,
    super.checkedInToday,
    super.workoutStreak,
    super.feeStatus,
    super.amount,
  });

  factory MemberListModel.fromJson(Map<String, dynamic> json) {
    return MemberListModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      plan: json['plan'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      joinDate: json['joinDate'] as String? ?? '',
      expiryDate: json['expiryDate'] as String? ?? '',
      daysLeft: json['daysLeft'] as num? ?? 0,
      trainer: json['trainer'] as String? ?? '',
      trainerId: json['trainerId'] as String? ?? '',
      checkedInToday: json['checkedInToday'] as bool? ?? false,
      workoutStreak: json['workoutStreak'] as num? ?? 0,
      feeStatus: json['feeStatus'] as String? ?? '',
      amount: json['amount'] as num? ?? 0,
    );
  }

  factory MemberListModel.fromEntity(MemberListEntity entity) {
    return MemberListModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      plan: entity.plan,
      planId: entity.planId,
      status: entity.status,
      joinDate: entity.joinDate,
      expiryDate: entity.expiryDate,
      daysLeft: entity.daysLeft,
      trainer: entity.trainer,
      trainerId: entity.trainerId,
      checkedInToday: entity.checkedInToday,
      workoutStreak: entity.workoutStreak,
      feeStatus: entity.feeStatus,
      amount: entity.amount,
    );
  }

  MemberListModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? plan,
    String? planId,
    String? status,
    String? joinDate,
    String? expiryDate,
    num? daysLeft,
    String? trainer,
    String? trainerId,
    bool? checkedInToday,
    num? workoutStreak,
    String? feeStatus,
    num? amount,
  }) => MemberListModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      planId: planId ?? this.planId,
      status: status ?? this.status,
      joinDate: joinDate ?? this.joinDate,
      expiryDate: expiryDate ?? this.expiryDate,
      daysLeft: daysLeft ?? this.daysLeft,
      trainer: trainer ?? this.trainer,
      trainerId: trainerId ?? this.trainerId,
      checkedInToday: checkedInToday ?? this.checkedInToday,
      workoutStreak: workoutStreak ?? this.workoutStreak,
      feeStatus: feeStatus ?? this.feeStatus,
      amount: amount ?? this.amount,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'plan': plan,
        'planId': planId,
        'status': status,
        'joinDate': joinDate,
        'expiryDate': expiryDate,
        'daysLeft': daysLeft,
        'trainer': trainer,
        'trainerId': trainerId,
        'checkedInToday': checkedInToday,
        'workoutStreak': workoutStreak,
        'feeStatus': feeStatus,
        'amount': amount,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MemberListModel('
      'id: $id, '
      'name: $name, '
      'phone: $phone, '
      'email: $email, '
      'plan: $plan, '
      'planId: $planId, '
      'status: $status, '
      'joinDate: $joinDate, '
      'expiryDate: $expiryDate, '
      'daysLeft: $daysLeft, '
      'trainer: $trainer, '
      'trainerId: $trainerId, '
      'checkedInToday: $checkedInToday, '
      'workoutStreak: $workoutStreak, '
      'feeStatus: $feeStatus, '
      'amount: $amount, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is MemberListModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

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

