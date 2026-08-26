import 'workout_manager_entities.dart';

class CreatedByEntity {
  final String id;
  final String name;
  final String role;

  const CreatedByEntity({
    this.id = '',
    this.name = '',
    this.role = '',
  });

  @override
  String toString() {
    return 'CreatedByEntity('
      'id: $id, '
      'name: $name, '
      'role: $role, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is CreatedByEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class ExerciseListEntity {
  final String id;
  final String dayId;
  final String exerciseId;
  final num sets;
  final num reps;
  final num restSeconds;
  final String notes;
  final num orderIndex;
  final ExerciseEntity exercise;

  const ExerciseListEntity({
    this.id = '',
    this.dayId = '',
    this.exerciseId = '',
    this.sets = 0,
    this.reps = 0,
    this.restSeconds = 0,
    this.notes = '',
    this.orderIndex = 0,
    this.exercise = const ExerciseEntity(),
  });

  @override
  String toString() {
    return 'ExerciseEntity('
      'id: $id, '
      'dayId: $dayId, '
      'exerciseId: $exerciseId, '
      'sets: $sets, '
      'reps: $reps, '
      'restSeconds: $restSeconds, '
      'notes: $notes, '
      'orderIndex: $orderIndex, '
      'exercise: $exercise, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is ExerciseEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class DayEntity {
  final String id;
  final String planId;
  final String dayOfWeek;
  final bool isRestDay;
  final List<ExerciseListEntity> exercises;

  const DayEntity({
    this.id = '',
    this.planId = '',
    this.dayOfWeek = '',
    this.isRestDay = false,
    this.exercises = const [],
  });

  @override
  String toString() {
    return 'DayEntity('
      'id: $id, '
      'planId: $planId, '
      'dayOfWeek: $dayOfWeek, '
      'isRestDay: $isRestDay, '
      'exercises: $exercises, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is DayEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

class TemplateDetailsEntity {
  final String id;
  final String name;
  final String type;
  final bool isTemplate;
  final String createdById;
  final String startDate;
  final String endDate;
  final String createdAt;
  final String updatedAt;
  final CreatedByEntity createdBy;
  final List<DayEntity> days;
  final List<AssignmentEntity> assignments;
  final CountEntity count;

  const TemplateDetailsEntity({
    this.id = '',
    this.name = '',
    this.type = '',
    this.isTemplate = false,
    this.createdById = '',
    this.startDate = '',
    this.endDate = '',
    this.createdAt = '',
    this.updatedAt = '',
    this.createdBy = const CreatedByEntity(),
    this.days = const [],
    this.assignments = const [],
    this.count = const CountEntity(),
  });

  @override
  String toString() {
    return 'TemplateDetailsEntity('
      'id: $id, '
      'name: $name, '
      'type: $type, '
      'isTemplate: $isTemplate, '
      'createdById: $createdById, '
      'startDate: $startDate, '
      'endDate: $endDate, '
      'createdAt: $createdAt, '
      'updatedAt: $updatedAt, '
      'createdBy: $createdBy, '
      'days: $days, '
      'count: $count, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is TemplateDetailsEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

