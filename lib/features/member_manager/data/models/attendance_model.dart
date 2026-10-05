
import '../../domain/entities/attendance_entity.dart';

class AttendanceModel extends AttendanceEntity {
  const AttendanceModel({
    super.id,
    super.memberId,
    super.checkInAt,
    super.checkOutAt,
    super.method,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) {
    return AttendanceModel(
      id: json['id'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      checkInAt: json['checkInAt'] as String? ?? '',
      checkOutAt: json['checkOutAt'] as String? ?? '',
      method: json['method'] as String? ?? '',
    );
  }

  factory AttendanceModel.fromEntity(AttendanceEntity entity) {
    return AttendanceModel(
      id: entity.id,
      memberId: entity.memberId,
      checkInAt: entity.checkInAt,
      checkOutAt: entity.checkOutAt,
      method: entity.method,
    );
  }

  AttendanceModel copyWith({
    String? id,
    String? memberId,
    String? checkInAt,
    String? checkOutAt,
    String? method,
  }) => AttendanceModel(
      id: id ?? this.id,
      memberId: memberId ?? this.memberId,
      checkInAt: checkInAt ?? this.checkInAt,
      checkOutAt: checkOutAt ?? this.checkOutAt,
      method: method ?? this.method,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'memberId': memberId,
        'checkInAt': checkInAt,
        'checkOutAt': checkOutAt,
        'method': method,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'AttendanceModel('
      'id: $id, '
      'memberId: $memberId, '
      'checkInAt: $checkInAt, '
      'checkOutAt: $checkOutAt, '
      'method: $method, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is AttendanceModel && other.id == id);
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

