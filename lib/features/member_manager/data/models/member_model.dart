import '../../domain/entities/member_entity.dart';
import 'member_manager_models.dart';

class MemberModel extends MemberEntity {
  const MemberModel({
    super.id,
    super.name,
    super.phone,
    super.email,
    super.passwordHash,
    super.profileImageUrl,
    super.role,
    super.status,
    super.googleId,
    super.firebaseUid,
    super.dateOfBirth,
    super.emergencyContact,
    super.medicalNotes,
    super.membershipPlanId,
    super.membershipStart,
    super.membershipEnd,
    super.contentAccessUntil,
    super.assignedTrainerId,
    super.staffTitle,
    super.hireDate,
    super.referralCode,
    super.referredById,
    super.createdAt,
    super.updatedAt,
    super.devicePin,
    super.deviceSN,
    super.blocked,
    super.graceEntriesUsed,
    super.assignedTrainer,
    super.workoutStreak,
    super.checkedInToday,
    super.membershipPlan,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      passwordHash: json['passwordHash'] as String? ?? '',
      profileImageUrl: json['profileImageUrl']?.toString() ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      googleId: json['googleId']?.toString() ?? '',
      firebaseUid: json['firebaseUid']?.toString() ?? '',
      dateOfBirth: json['dateOfBirth']?.toString() ?? '',
      emergencyContact: json['emergencyContact']?.toString() ?? '',
      medicalNotes: json['medicalNotes']?.toString() ?? '',
      membershipPlanId: json['membershipPlanId'] as String? ?? '',
      membershipStart: json['membershipStart'] as String? ?? '',
      membershipEnd: json['membershipEnd'] as String? ?? '',
      contentAccessUntil: json['contentAccessUntil']?.toString() ?? '',
      assignedTrainerId: json['assignedTrainerId'] as String? ?? '',
      staffTitle: json['staffTitle']?.toString() ?? '',
      hireDate: json['hireDate']?.toString() ?? '',
      referralCode: json['referralCode']?.toString() ?? '',
      referredById: json['referredById']?.toString() ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      devicePin: json['devicePin']?.toString() ?? '',
      deviceSN: json['deviceSN']?.toString() ?? '',
      blocked: json['blocked'] as bool? ?? false,
      graceEntriesUsed: json['graceEntriesUsed'] as num? ?? 0,
      assignedTrainer: json['assignedTrainer'] as String? ?? '',
      workoutStreak: json['workoutStreak'] as num? ?? 0,
      checkedInToday: json['checkedInToday'] as bool? ?? false,
      membershipPlan: MembershipPlanMiniModel.fromJson(
        json['membershipPlan'] ?? {},
      ),
    );
  }

  factory MemberModel.fromEntity(MemberEntity entity) {
    return MemberModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      passwordHash: entity.passwordHash,
      profileImageUrl: entity.profileImageUrl,
      role: entity.role,
      status: entity.status,
      googleId: entity.googleId,
      firebaseUid: entity.firebaseUid,
      dateOfBirth: entity.dateOfBirth,
      emergencyContact: entity.emergencyContact,
      medicalNotes: entity.medicalNotes,
      membershipPlanId: entity.membershipPlanId,
      membershipStart: entity.membershipStart,
      membershipEnd: entity.membershipEnd,
      contentAccessUntil: entity.contentAccessUntil,
      assignedTrainerId: entity.assignedTrainerId,
      staffTitle: entity.staffTitle,
      hireDate: entity.hireDate,
      referralCode: entity.referralCode,
      referredById: entity.referredById,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      devicePin: entity.devicePin,
      deviceSN: entity.deviceSN,
      blocked: entity.blocked,
      graceEntriesUsed: entity.graceEntriesUsed,
      assignedTrainer: entity.assignedTrainer,
      workoutStreak: entity.workoutStreak,
      checkedInToday: entity.checkedInToday,
      membershipPlan: entity.membershipPlan,
    );
  }

  MemberModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? passwordHash,
    String? profileImageUrl,
    String? role,
    String? status,
    String? googleId,
    String? firebaseUid,
    String? dateOfBirth,
    String? emergencyContact,
    String? medicalNotes,
    String? membershipPlanId,
    String? membershipStart,
    String? membershipEnd,
    String? contentAccessUntil,
    String? assignedTrainerId,
    String? staffTitle,
    String? hireDate,
    String? referralCode,
    String? referredById,
    String? createdAt,
    String? updatedAt,
    String? devicePin,
    String? deviceSN,
    bool? blocked,
    num? graceEntriesUsed,
    String? assignedTrainer,
    num? workoutStreak,
    bool? checkedInToday,
    MembershipPlanMiniModel? membershipPlan,
  }) => MemberModel(
    id: id ?? this.id,
    name: name ?? this.name,
    phone: phone ?? this.phone,
    email: email ?? this.email,
    passwordHash: passwordHash ?? this.passwordHash,
    profileImageUrl: profileImageUrl ?? this.profileImageUrl,
    role: role ?? this.role,
    status: status ?? this.status,
    googleId: googleId ?? this.googleId,
    firebaseUid: firebaseUid ?? this.firebaseUid,
    dateOfBirth: dateOfBirth ?? this.dateOfBirth,
    emergencyContact: emergencyContact ?? this.emergencyContact,
    medicalNotes: medicalNotes ?? this.medicalNotes,
    membershipPlanId: membershipPlanId ?? this.membershipPlanId,
    membershipStart: membershipStart ?? this.membershipStart,
    membershipEnd: membershipEnd ?? this.membershipEnd,
    contentAccessUntil: contentAccessUntil ?? this.contentAccessUntil,
    assignedTrainerId: assignedTrainerId ?? this.assignedTrainerId,
    staffTitle: staffTitle ?? this.staffTitle,
    hireDate: hireDate ?? this.hireDate,
    referralCode: referralCode ?? this.referralCode,
    referredById: referredById ?? this.referredById,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    devicePin: devicePin ?? this.devicePin,
    deviceSN: deviceSN ?? this.deviceSN,
    blocked: blocked ?? this.blocked,
    graceEntriesUsed: graceEntriesUsed ?? this.graceEntriesUsed,
    assignedTrainer: assignedTrainer ?? this.assignedTrainer,
    workoutStreak: workoutStreak ?? this.workoutStreak,
    checkedInToday: checkedInToday ?? this.checkedInToday,
    membershipPlan: membershipPlan ?? this.membershipPlan,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'email': email,
    'passwordHash': passwordHash,
    'profileImageUrl': profileImageUrl,
    'role': role,
    'status': status,
    'googleId': googleId,
    'firebaseUid': firebaseUid,
    'dateOfBirth': dateOfBirth,
    'emergencyContact': emergencyContact,
    'medicalNotes': medicalNotes,
    'membershipPlanId': membershipPlanId,
    'membershipStart': membershipStart,
    'membershipEnd': membershipEnd,
    'contentAccessUntil': contentAccessUntil,
    'assignedTrainerId': assignedTrainerId,
    'staffTitle': staffTitle,
    'hireDate': hireDate,
    'referralCode': referralCode,
    'referredById': referredById,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'devicePin': devicePin,
    'deviceSN': deviceSN,
    'blocked': blocked,
    'graceEntriesUsed': graceEntriesUsed,
    'assignedTrainer': assignedTrainer,
    'workoutStreak': workoutStreak,
    'checkedInToday': checkedInToday,
    'membershipPlan': MembershipPlanMiniModel.fromEntity(
      membershipPlan,
    ).toJson(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MemberModel('
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
    return identical(this, other) || (other is MemberModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}
