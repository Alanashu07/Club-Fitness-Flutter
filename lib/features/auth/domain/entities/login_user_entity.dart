class LoginUserEntity {
  final String id;
  final String name;
  final String phone;
  final String email;
  final String profileImageUrl;
  final String role;
  final String status;
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

  const LoginUserEntity({
    this.id = '',
    this.name = '',
    this.phone = '',
    this.email = '',
    this.profileImageUrl = '',
    this.role = '',
    this.status = '',
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
  });

  @override
  String toString() {
    return 'LoginUserEntity('
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
    return identical(this, other) || (other is LoginUserEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
