import '../../domain/entities/workout_day_input_entity.dart';

class ExerciseInputModel extends ExerciseInputEntity {
  const ExerciseInputModel({
    super.exerciseId,
    super.sets,
    super.reps,
    super.restSeconds,
    super.notes,
    super.orderIndex,
  });

  factory ExerciseInputModel.fromJson(Map<String, dynamic> json) {
    return ExerciseInputModel(
      exerciseId: json['exerciseId'] as String? ?? '',
      sets: json['sets'] as num? ?? 0,
      reps: json['reps'] as num? ?? 0,
      restSeconds: json['restSeconds'] as num? ?? 0,
      notes: json['notes'] as String? ?? '',
      orderIndex: json['orderIndex'] as num? ?? 0,
    );
  }

  factory ExerciseInputModel.fromEntity(ExerciseInputEntity entity) {
    return ExerciseInputModel(
      exerciseId: entity.exerciseId,
      sets: entity.sets,
      reps: entity.reps,
      restSeconds: entity.restSeconds,
      notes: entity.notes,
      orderIndex: entity.orderIndex,
    );
  }

  ExerciseInputModel copyWith({
    String? exerciseId,
    num? sets,
    num? reps,
    num? restSeconds,
    String? notes,
    num? orderIndex,
  }) => ExerciseInputModel(
      exerciseId: exerciseId ?? this.exerciseId,
      sets: sets ?? this.sets,
      reps: reps ?? this.reps,
      restSeconds: restSeconds ?? this.restSeconds,
      notes: notes ?? this.notes,
      orderIndex: orderIndex ?? this.orderIndex,
  );

  Map<String, dynamic> toJson() => {
        'exerciseId': exerciseId,
        'sets': sets,
        'reps': reps,
        'restSeconds': restSeconds,
        'notes': notes,
        'orderIndex': orderIndex,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'ExerciseInputModel('
      'exerciseId: $exerciseId, '
      'sets: $sets, '
      'reps: $reps, '
      'restSeconds: $restSeconds, '
      'notes: $notes, '
      'orderIndex: $orderIndex, '
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

class WorkoutDayInputModel extends WorkoutDayInputEntity {
  const WorkoutDayInputModel({
    super.dayOfWeek,
    super.isRestDay,
    super.exercises,
  });

  factory WorkoutDayInputModel.fromJson(Map<String, dynamic> json) {
    return WorkoutDayInputModel(
      dayOfWeek: json['dayOfWeek'] as String? ?? '',
      isRestDay: json['isRestDay'] as bool? ?? false,
      exercises: (json['exercises'] as List?)?.map((e) => ExerciseInputModel.fromJson(e)).toList() ?? const [],
    );
  }

  factory WorkoutDayInputModel.fromEntity(WorkoutDayInputEntity entity) {
    return WorkoutDayInputModel(
      dayOfWeek: entity.dayOfWeek,
      isRestDay: entity.isRestDay,
      exercises: entity.exercises,
    );
  }

  WorkoutDayInputModel copyWith({
    String? dayOfWeek,
    bool? isRestDay,
    List<ExerciseInputModel>? exercises,
  }) => WorkoutDayInputModel(
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      isRestDay: isRestDay ?? this.isRestDay,
      exercises: exercises ?? this.exercises,
  );

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'isRestDay': isRestDay,
        'exercises': exercises.map((e) => ExerciseInputModel.fromEntity(e).toJson()).toList(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'WorkoutDayInputModel('
      'dayOfWeek: $dayOfWeek, '
      'isRestDay: $isRestDay, '
      'exercises: $exercises, '
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

