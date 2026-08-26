class MemberEntity {
  final String id;
  final String name;
  final String phone;

  const MemberEntity({
    this.id = '',
    this.name = '',
    this.phone = '',
  });

  @override
  String toString() {
    return 'MemberEntity('
      'id: $id, '
      'name: $name, '
      'phone: $phone, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is MemberEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class PlanEntity {
  final String id;
  final String name;
  final String type;

  const PlanEntity({
    this.id = '',
    this.name = '',
    this.type = '',
  });

  @override
  String toString() {
    return 'PlanEntity('
      'id: $id, '
      'name: $name, '
      'type: $type, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PlanEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class AssignmentEntity {
  final String id;
  final String planId;
  final String memberId;
  final String startDate;
  final String endDate;
  final bool notifySent;
  final dynamic completedExerciseIds;
  final String assignedAt;
  final MemberEntity member;
  final PlanEntity plan;

  const AssignmentEntity({
    this.id = '',
    this.planId = '',
    this.memberId = '',
    this.startDate = '',
    this.endDate = '',
    this.notifySent = false,
    this.completedExerciseIds = const [],
    this.assignedAt = '',
    this.member = const MemberEntity(),
    this.plan = const PlanEntity(),
  });

  @override
  String toString() {
    return 'AssignmentEntity('
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
    return identical(this, other) || (other is AssignmentEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class AssignWorkoutResponseEntity {
  final String message;
  final num assigned;
  final num skipped;
  final List<AssignmentEntity> assignments;

  const AssignWorkoutResponseEntity({
    this.message = '',
    this.assigned = 0,
    this.skipped = 0,
    this.assignments = const [],
  });

  @override
  String toString() {
    return 'AssignWorkoutResponseEntity('
      'message: $message, '
      'assigned: $assigned, '
      'skipped: $skipped, '
      'assignments: $assignments, '
    ')';
  }
}

