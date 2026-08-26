
import '../../domain/entities/login_user_entity.dart';

class LoginUserModel extends LoginUserEntity {
  const LoginUserModel({
    super.id,
    super.name,
    super.phone,
    super.email,
    super.profileImageUrl,
    super.role,
    super.status,
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
  });

  factory LoginUserModel.fromJson(Map<String, dynamic> json) {
    return LoginUserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      dateOfBirth: json['dateOfBirth'] as String? ?? '',
      emergencyContact: json['emergencyContact'] as String? ?? '',
      medicalNotes: json['medicalNotes'] as String? ?? '',
      membershipPlanId: json['membershipPlanId'] as String? ?? '',
      membershipStart: json['membershipStart'] as String? ?? '',
      membershipEnd: json['membershipEnd'] as String? ?? '',
      contentAccessUntil: json['contentAccessUntil'] as String? ?? '',
      assignedTrainerId: json['assignedTrainerId'] as String? ?? '',
      staffTitle: json['staffTitle'] as String? ?? '',
      hireDate: json['hireDate'] as String? ?? '',
      referralCode: json['referralCode'] as String? ?? '',
      referredById: json['referredById'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
    );
  }

  factory LoginUserModel.fromEntity(LoginUserEntity entity) {
    return LoginUserModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      profileImageUrl: entity.profileImageUrl,
      role: entity.role,
      status: entity.status,
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
    );
  }

  LoginUserModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? profileImageUrl,
    String? role,
    String? status,
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
  }) => LoginUserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      role: role ?? this.role,
      status: status ?? this.status,
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
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
        'email': email,
        'profileImageUrl': profileImageUrl,
        'role': role,
        'status': status,
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
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'LoginUserModel('
      'id: $id, '
      'name: $name, '
      'phone: $phone, '
      'email: $email, '
      'profileImageUrl: $profileImageUrl, '
      'role: $role, '
      'status: $status, '
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
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is LoginUserModel && other.id == id);
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

