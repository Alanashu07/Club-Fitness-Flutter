import '../../domain/entities/template_details_entity.dart';
import 'workout_manager_models.dart';

class CreatedByModel extends CreatedByEntity {
  const CreatedByModel({super.id, super.name, super.role});

  factory CreatedByModel.fromJson(Map<String, dynamic> json) {
    return CreatedByModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      role: json['role'] as String? ?? '',
    );
  }

  factory CreatedByModel.fromEntity(CreatedByEntity entity) {
    return CreatedByModel(id: entity.id, name: entity.name, role: entity.role);
  }

  CreatedByModel copyWith({String? id, String? name, String? role}) =>
      CreatedByModel(
        id: id ?? this.id,
        name: name ?? this.name,
        role: role ?? this.role,
      );

  Map<String, dynamic> toJson() =>
      {'id': id, 'name': name, 'role': role}
        ..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'CreatedByModel('
        'id: $id, '
        'name: $name, '
        'role: $role, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is CreatedByModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class ExerciseListModel extends ExerciseListEntity {
  const ExerciseListModel({
    super.id,
    super.dayId,
    super.exerciseId,
    super.sets,
    super.reps,
    super.restSeconds,
    super.notes,
    super.orderIndex,
    super.exercise,
  });

  factory ExerciseListModel.fromJson(Map<String, dynamic> json) {
    return ExerciseListModel(
      id: json['id'] as String? ?? '',
      dayId: json['dayId'] as String? ?? '',
      exerciseId: json['exerciseId'] as String? ?? '',
      sets: json['sets'] as num? ?? 0,
      reps: json['reps'] as num? ?? 0,
      restSeconds: json['restSeconds'] as num? ?? 0,
      notes: json['notes'] as String? ?? '',
      orderIndex: json['orderIndex'] as num? ?? 0,
      exercise: json['exercise'] != null
          ? ExerciseModel.fromJson(json['exercise'])
          : const ExerciseModel(),
    );
  }

  factory ExerciseListModel.fromEntity(ExerciseListEntity entity) {
    return ExerciseListModel(
      id: entity.id,
      dayId: entity.dayId,
      exerciseId: entity.exerciseId,
      sets: entity.sets,
      reps: entity.reps,
      restSeconds: entity.restSeconds,
      notes: entity.notes,
      orderIndex: entity.orderIndex,
      exercise: entity.exercise,
    );
  }

  ExerciseListModel copyWith({
    String? id,
    String? dayId,
    String? exerciseId,
    num? sets,
    num? reps,
    num? restSeconds,
    String? notes,
    num? orderIndex,
    ExerciseModel? exercise,
  }) => ExerciseListModel(
    id: id ?? this.id,
    dayId: dayId ?? this.dayId,
    exerciseId: exerciseId ?? this.exerciseId,
    sets: sets ?? this.sets,
    reps: reps ?? this.reps,
    restSeconds: restSeconds ?? this.restSeconds,
    notes: notes ?? this.notes,
    orderIndex: orderIndex ?? this.orderIndex,
    exercise: exercise ?? this.exercise,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'dayId': dayId,
    'exerciseId': exerciseId,
    'sets': sets,
    'reps': reps,
    'restSeconds': restSeconds,
    'notes': notes,
    'orderIndex': orderIndex,
    'exercise': ExerciseModel.fromEntity(exercise).toJson(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ExerciseModel('
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
    return identical(this, other) || (other is ExerciseModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class DayModel extends DayEntity {
  const DayModel({
    super.id,
    super.planId,
    super.dayOfWeek,
    super.isRestDay,
    super.exercises,
  });

  factory DayModel.fromJson(Map<String, dynamic> json) {
    return DayModel(
      id: json['id'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      dayOfWeek: json['dayOfWeek'] as String? ?? '',
      isRestDay: json['isRestDay'] as bool? ?? false,
      exercises:
          (json['exercises'] as List?)
              ?.map((e) => ExerciseListModel.fromJson(e))
              .toList() ??
          const [],
    );
  }

  factory DayModel.fromEntity(DayEntity entity) {
    return DayModel(
      id: entity.id,
      planId: entity.planId,
      dayOfWeek: entity.dayOfWeek,
      isRestDay: entity.isRestDay,
      exercises: entity.exercises,
    );
  }

  DayModel copyWith({
    String? id,
    String? planId,
    String? dayOfWeek,
    bool? isRestDay,
    List<ExerciseListModel>? exercises,
  }) => DayModel(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    dayOfWeek: dayOfWeek ?? this.dayOfWeek,
    isRestDay: isRestDay ?? this.isRestDay,
    exercises: exercises ?? this.exercises,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'planId': planId,
    'dayOfWeek': dayOfWeek,
    'isRestDay': isRestDay,
    'exercises': exercises
        .map((e) => ExerciseListModel.fromEntity(e).toJson())
        .toList(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'DayModel('
        'id: $id, '
        'planId: $planId, '
        'dayOfWeek: $dayOfWeek, '
        'isRestDay: $isRestDay, '
        'exercises: $exercises, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is DayModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}

class TemplateDetailsModel extends TemplateDetailsEntity {
  const TemplateDetailsModel({
    super.id,
    super.name,
    super.type,
    super.isTemplate,
    super.createdById,
    super.startDate,
    super.endDate,
    super.createdAt,
    super.updatedAt,
    super.createdBy,
    super.days,
    super.assignments,
    super.count,
  });

  factory TemplateDetailsModel.fromJson(Map<String, dynamic> json) {
    return TemplateDetailsModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isTemplate: json['isTemplate'] as bool? ?? false,
      createdById: json['createdById'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      createdBy: json['createdBy'] != null
          ? CreatedByModel.fromJson(json['createdBy'])
          : const CreatedByModel(),
      days:
          (json['days'] as List?)?.map((e) => DayModel.fromJson(e)).toList() ??
          const [],
      assignments:
          (json['assignments'] as List?)
              ?.map((e) => AssignmentModel.fromJson(e))
              .toList() ??
          const [],
      count: json['_count'] != null
          ? CountModel.fromJson(json['_count'])
          : const CountModel(),
    );
  }

  factory TemplateDetailsModel.fromEntity(TemplateDetailsEntity entity) {
    return TemplateDetailsModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      isTemplate: entity.isTemplate,
      createdById: entity.createdById,
      startDate: entity.startDate,
      endDate: entity.endDate,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      createdBy: entity.createdBy,
      days: entity.days,
      assignments: entity.assignments,
      count: entity.count,
    );
  }

  TemplateDetailsModel copyWith({
    String? id,
    String? name,
    String? type,
    bool? isTemplate,
    String? createdById,
    String? startDate,
    String? endDate,
    String? createdAt,
    String? updatedAt,
    CreatedByModel? createdBy,
    List<DayModel>? days,
    List<AssignmentModel>? assignments,
    CountModel? count,
  }) => TemplateDetailsModel(
    id: id ?? this.id,
    name: name ?? this.name,
    type: type ?? this.type,
    isTemplate: isTemplate ?? this.isTemplate,
    createdById: createdById ?? this.createdById,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    createdBy: createdBy ?? this.createdBy,
    days: days ?? this.days,
    assignments: assignments ?? this.assignments,
    count: count ?? this.count,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'isTemplate': isTemplate,
    'createdById': createdById,
    'startDate': startDate,
    'endDate': endDate,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'createdBy': CreatedByModel.fromEntity(createdBy).toJson(),
    'days': days.map((e) => DayModel.fromEntity(e).toJson()).toList(),
    'assignments': assignments
        .map((e) => AssignmentModel.fromEntity(e).toJson())
        .toList(),
    '_count': CountModel.fromEntity(count).toJson(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'TemplateDetailsModel('
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
        '_count: $count, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is TemplateDetailsModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}
