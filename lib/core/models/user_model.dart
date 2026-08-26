
import '../entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    super.id,
    super.name,
    super.email,
    super.phone,
    super.role,
    super.status,
    super.profileImageUrl,
    super.membershipPlanId,
    super.membershipEnd,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      role: json['role'] as String? ?? '',
      status: json['status'] as String? ?? '',
      profileImageUrl: json['profileImageUrl'] as String? ?? '',
      membershipPlanId: json['membershipPlanId'] as String? ?? '',
      membershipEnd: json['membershipEnd'] as String? ?? '',
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      email: entity.email,
      phone: entity.phone,
      role: entity.role,
      status: entity.status,
      profileImageUrl: entity.profileImageUrl,
      membershipPlanId: entity.membershipPlanId,
      membershipEnd: entity.membershipEnd,
    );
  }

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    String? role,
    String? status,
    String? profileImageUrl,
    String? membershipPlanId,
    String? membershipEnd,
  }) => UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      status: status ?? this.status,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      membershipPlanId: membershipPlanId ?? this.membershipPlanId,
      membershipEnd: membershipEnd ?? this.membershipEnd,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone': phone,
        'role': role,
        'status': status,
        'profileImageUrl': profileImageUrl,
        'membershipPlanId': membershipPlanId,
        'membershipEnd': membershipEnd,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'UserModel('
      'id: $id, '
      'name: $name, '
      'email: $email, '
      'phone: $phone, '
      'role: $role, '
      'status: $status, '
      'profileImageUrl: $profileImageUrl, '
      'membershipPlanId: $membershipPlanId, '
      'membershipEnd: $membershipEnd, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is UserModel && other.id == id);
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

