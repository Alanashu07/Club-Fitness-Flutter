import 'package:club_fitness/config/theme/theme.dart';
import 'package:club_fitness/core/entities/member_status.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:flutter/material.dart';

import 'member_manager_entities.dart';

class MemberEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String passwordHash;
  final String profileImageUrl;
  final String role;
  final String status;
  final String googleId;
  final String firebaseUid;
  final String dateOfBirth;
  final String emergencyContact;
  final String medicalNotes;
  final String membershipPlanId;
  final String membershipStart;
  final String membershipEnd;
  final String contentAccessUntil;
  final String assignedTrainerId;
  final String staffTitle;
  final String hireDate;
  final String referralCode;
  final String referredById;
  final String createdAt;
  final String updatedAt;
  final String devicePin;
  final String deviceSN;
  final bool blocked;
  final num graceEntriesUsed;
  final String assignedTrainer;
  final num workoutStreak;
  final bool checkedInToday;
  final MembershipPlanMiniEntity membershipPlan;

  const MemberEntity({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.passwordHash = '',
    this.profileImageUrl = '',
    this.role = '',
    this.status = '',
    this.googleId = '',
    this.firebaseUid = '',
    this.dateOfBirth = '',
    this.emergencyContact = '',
    this.medicalNotes = '',
    this.membershipPlanId = '',
    this.membershipStart = '',
    this.membershipEnd = '',
    this.contentAccessUntil = '',
    this.assignedTrainerId = '',
    this.staffTitle = '',
    this.hireDate = '',
    this.referralCode = '',
    this.referredById = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.devicePin = '',
    this.deviceSN = '',
    this.blocked = false,
    this.graceEntriesUsed = 0,
    this.assignedTrainer = '',
    this.workoutStreak = 0,
    this.checkedInToday = false,
    this.membershipPlan = const MembershipPlanMiniEntity(),
  });

  @override
  String toString() {
    return 'MemberEntity('
        'id: $id, '
        'name: $name, '
        'phone: $phone, '
        'email: $email, '
        'passwordHash: $passwordHash, '
        'profileImageUrl: $profileImageUrl, '
        'role: $role, '
        'status: $status, '
        'googleId: $googleId, '
        'firebaseUid: $firebaseUid, '
        'dateOfBirth: $dateOfBirth, '
        'emergencyContact: $emergencyContact, '
        'medicalNotes: $medicalNotes, '
        'membershipPlanId: $membershipPlanId, '
        'membershipStart: $membershipStart, '
        'membershipEnd: $membershipEnd, '
        'contentAccessUntil: $contentAccessUntil, '
        'assignedTrainerId: $assignedTrainerId, '
        'staffTitle: $staffTitle, '
        'hireDate: $hireDate, '
        'referralCode: $referralCode, '
        'referredById: $referredById, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'devicePin: $devicePin, '
        'deviceSN: $deviceSN, '
        'blocked: $blocked, '
        'graceEntriesUsed: $graceEntriesUsed, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is MemberEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

extension MemberExtension on MemberEntity {
  MemberStatus get memberStatus => MemberStatus.fromKey(status);
  String get initials => name.twoLetters;
  Color get avatarColor {
    final colors = AppTheme.palette;
    return colors[Randomizer.clampInt(id.hashCode, colors.length)];
  }

  DateTime get membershipStartDate => membershipStart.toDateTime;
  DateTime get membershipEndDate => membershipEnd.toDateTime;
  DateTime get createdAtDate => createdAt.toDateTime;
  DateTime get updatedAtDate => updatedAt.toDateTime;
  int get daysLeft {
    return membershipEndDate.difference(DateTime.now()).inDays;
  }
}
