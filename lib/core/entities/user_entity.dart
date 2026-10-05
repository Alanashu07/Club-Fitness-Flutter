import 'package:club_fitness/core/utils/utils.dart';

enum UserRole {
  admin('ADMIN', 'Admin'),
  trainer('STAFF', 'Trainer'),
  member('MEMBER', 'Member');

  const UserRole(this.key, this.label);
  final String key;
  final String label;

  static UserRole fromKey(String? key) {
    return values.firstWhere((e) => e.key == key?.toUpperCase(), orElse: () => member);
  }
}

class UserEntity {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String profileImageUrl;
  final String membershipPlanId;
  final String membershipEnd;

  const UserEntity({
    this.id = '',
    this.name = '',
    this.email = '',
    this.phone = '',
    this.role = '',
    this.status = '',
    this.profileImageUrl = '',
    this.membershipPlanId = '',
    this.membershipEnd = '',
  });

  String get initials {
    return name.twoLetters;
  }

  @override
  String toString() {
    return 'UserEntity('
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
    return identical(this, other) || (other is UserEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

extension UserExtension on UserEntity {
  UserRole get userRole => UserRole.fromKey(role);
}
