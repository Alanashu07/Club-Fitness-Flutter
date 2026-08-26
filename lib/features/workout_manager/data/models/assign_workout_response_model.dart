import '../../domain/entities/assign_workout_response_entity.dart';

class MemberModel extends MemberEntity {
  const MemberModel({
    super.id,
    super.name,
    super.phone,
  });

  factory MemberModel.fromJson(Map<String, dynamic> json) {
    return MemberModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
    );
  }

  factory MemberModel.fromEntity(MemberEntity entity) {
    return MemberModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
    );
  }

  MemberModel copyWith({
    String? id,
    String? name,
    String? phone,
  }) => MemberModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'phone': phone,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MemberModel('
      'id: $id, '
      'name: $name, '
      'phone: $phone, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is MemberModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty values
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

class PlanModel extends PlanEntity {
  const PlanModel({
    super.id,
    super.name,
    super.type,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
    );
  }

  factory PlanModel.fromEntity(PlanEntity entity) {
    return PlanModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
    );
  }

  PlanModel copyWith({
    String? id,
    String? name,
    String? type,
  }) => PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'PlanModel('
      'id: $id, '
      'name: $name, '
      'type: $type, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PlanModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty values
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

class AssignmentModel extends AssignmentEntity {
  const AssignmentModel({
    super.id,
    super.planId,
    super.memberId,
    super.startDate,
    super.endDate,
    super.notifySent,
    super.completedExerciseIds,
    super.assignedAt,
    super.member,
    super.plan,
  });

  factory AssignmentModel.fromJson(Map<String, dynamic> json) {
    return AssignmentModel(
      id: json['id'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      memberId: json['memberId'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      notifySent: json['notifySent'] as bool? ?? false,
      completedExerciseIds: json['completedExerciseIds'] as dynamic? ?? const [],
      assignedAt: json['assignedAt'] as String? ?? '',
      member: json['member'] != null ? MemberModel.fromJson(json['member']) : const MemberModel(),
      plan: json['plan'] != null ? PlanModel.fromJson(json['plan']) : const PlanModel(),
    );
  }

  factory AssignmentModel.fromEntity(AssignmentEntity entity) {
    return AssignmentModel(
      id: entity.id,
      planId: entity.planId,
      memberId: entity.memberId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      notifySent: entity.notifySent,
      completedExerciseIds: entity.completedExerciseIds,
      assignedAt: entity.assignedAt,
      member: entity.member,
      plan: entity.plan,
    );
  }

  AssignmentModel copyWith({
    String? id,
    String? planId,
    String? memberId,
    String? startDate,
    String? endDate,
    bool? notifySent,
    dynamic? completedExerciseIds,
    String? assignedAt,
    MemberModel? member,
    PlanModel? plan,
  }) => AssignmentModel(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      memberId: memberId ?? this.memberId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      notifySent: notifySent ?? this.notifySent,
      completedExerciseIds: completedExerciseIds ?? this.completedExerciseIds,
      assignedAt: assignedAt ?? this.assignedAt,
      member: member ?? this.member,
      plan: plan ?? this.plan,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'planId': planId,
        'memberId': memberId,
        'startDate': startDate,
        'endDate': endDate,
        'notifySent': notifySent,
        'completedExerciseIds': completedExerciseIds,
        'assignedAt': assignedAt,
        'member': MemberModel.fromEntity(member).toJson(),
        'plan': PlanModel.fromEntity(plan).toJson(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'AssignmentModel('
      'id: $id, '
      'planId: $planId, '
      'memberId: $memberId, '
      'startDate: $startDate, '
      'endDate: $endDate, '
      'notifySent: $notifySent, '
      'completedExerciseIds: $completedExerciseIds, '
      'assignedAt: $assignedAt, '
      'member: $member, '
      'plan: $plan, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is AssignmentModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty values
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

class AssignWorkoutResponseModel extends AssignWorkoutResponseEntity {
  const AssignWorkoutResponseModel({
    super.message,
    super.assigned,
    super.skipped,
    super.assignments,
  });

  factory AssignWorkoutResponseModel.fromJson(Map<String, dynamic> json) {
    return AssignWorkoutResponseModel(
      message: json['message'] as String? ?? '',
      assigned: json['assigned'] as num? ?? 0,
      skipped: json['skipped'] as num? ?? 0,
      assignments: (json['assignments'] as List?)?.map((e) => AssignmentModel.fromJson(e)).toList() ?? const [],
    );
  }

  factory AssignWorkoutResponseModel.fromEntity(AssignWorkoutResponseEntity entity) {
    return AssignWorkoutResponseModel(
      message: entity.message,
      assigned: entity.assigned,
      skipped: entity.skipped,
      assignments: entity.assignments,
    );
  }

  AssignWorkoutResponseModel copyWith({
    String? message,
    num? assigned,
    num? skipped,
    List<AssignmentModel>? assignments,
  }) => AssignWorkoutResponseModel(
      message: message ?? this.message,
      assigned: assigned ?? this.assigned,
      skipped: skipped ?? this.skipped,
      assignments: assignments ?? this.assignments,
  );

  Map<String, dynamic> toJson() => {
        'message': message,
        'assigned': assigned,
        'skipped': skipped,
        'assignments': assignments.map((e) => AssignmentModel.fromEntity(e).toJson()).toList(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'AssignWorkoutResponseModel('
      'message: $message, '
      'assigned: $assigned, '
      'skipped: $skipped, '
      'assignments: $assignments, '
    ')';
  }

  // Helper function to remove empty values
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

