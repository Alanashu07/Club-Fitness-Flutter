import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/entities/member_status.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:flutter/material.dart';

class MemberListEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String plan;
  final String planId;
  final String status;
  final String joinDate;
  final String expiryDate;
  final num daysLeft;
  final String trainer;
  final String trainerId;
  final bool checkedInToday;
  final num workoutStreak;
  final String feeStatus;
  final num amount;

  MemberStatus get memberStatus => MemberStatus.fromKey(status);
  String get initials => name.twoLetters;

  const MemberListEntity({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.plan = '',
    this.planId = '',
    this.status = '',
    this.joinDate = '',
    this.expiryDate = '',
    this.daysLeft = 0,
    this.trainer = '',
    this.trainerId = '',
    this.checkedInToday = false,
    this.workoutStreak = 0,
    this.feeStatus = '',
    this.amount = 0,
  });

  Color get avatarColor {
    final colors = AppTheme.palette;
    return colors[Randomizer.clampInt(id.hashCode, colors.length)];
  }

  @override
  String toString() {
    return 'MemberListEntity('
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
    return identical(this, other) ||
        (other is MemberListEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
