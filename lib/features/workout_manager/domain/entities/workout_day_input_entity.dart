class ExerciseInputEntity {
  final String exerciseId;
  final num sets;
  final num reps;
  final num restSeconds;
  final String notes;
  final num orderIndex;

  const ExerciseInputEntity({
    this.exerciseId = '',
    this.sets = 0,
    this.reps = 0,
    this.restSeconds = 0,
    this.notes = '',
    this.orderIndex = 0,
  });

  @override
  String toString() {
    return 'ExerciseInputEntity('
      'exerciseId: $exerciseId, '
      'sets: $sets, '
      'reps: $reps, '
      'restSeconds: $restSeconds, '
      'notes: $notes, '
      'orderIndex: $orderIndex, '
    ')';
  }
}

class WorkoutDayInputEntity {
  final String dayOfWeek;
  final bool isRestDay;
  final List<ExerciseInputEntity> exercises;

  const WorkoutDayInputEntity({
    this.dayOfWeek = '',
    this.isRestDay = false,
    this.exercises = const [],
  });

  @override
  String toString() {
    return 'WorkoutDayInputEntity('
      'dayOfWeek: $dayOfWeek, '
      'isRestDay: $isRestDay, '
      'exercises: $exercises, '
    ')';
  }
}

