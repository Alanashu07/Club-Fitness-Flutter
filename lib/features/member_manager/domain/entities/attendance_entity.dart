class AttendanceEntity {
  final String id;
  final String memberId;
  final String checkInAt;
  final String checkOutAt;
  final String method;

  const AttendanceEntity({
    this.id = '',
    this.memberId = '',
    this.checkInAt = '',
    this.checkOutAt = '',
    this.method = '',
  });

  @override
  String toString() {
    return 'AttendanceEntity('
      'id: $id, '
      'memberId: $memberId, '
      'checkInAt: $checkInAt, '
      'checkOutAt: $checkOutAt, '
      'method: $method, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is AttendanceEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
