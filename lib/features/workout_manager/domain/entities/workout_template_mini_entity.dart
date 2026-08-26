import 'workout_manager_entities.dart';

class DayBreakdowEntity {
  final String day;
  final bool isRestDay;
  final num exerciseCount;

  const DayBreakdowEntity({
    this.day = '',
    this.isRestDay = false,
    this.exerciseCount = 0,
  });

  @override
  String toString() {
    return 'DayBreakdowEntity('
        'day: $day, '
        'isRestDay: $isRestDay, '
        'exerciseCount: $exerciseCount, '
        ')';
  }
}

class WorkoutTemplateMiniEntity {
  final String id;
  final String name;
  final String type;
  final CreatedByEntity createdBy;
  final String startDate;
  final String endDate;
  final num timesAssigned;
  final num totalExercises;
  final List<DayBreakdowEntity> dayBreakdown;
  final String createdAt;

  const WorkoutTemplateMiniEntity({
    this.id = '',
    this.name = '',
    this.type = '',
    this.createdBy = const CreatedByEntity(),
    this.startDate = '',
    this.endDate = '',
    this.timesAssigned = 0,
    this.totalExercises = 0,
    this.dayBreakdown = const [],
    this.createdAt = '',
  });

  @override
  String toString() {
    return 'WorkoutTemplateMiniEntity('
        'id: $id, '
        'name: $name, '
        'type: $type, '
        'createdBy: $createdBy, '
        'startDate: $startDate, '
        'endDate: $endDate, '
        'timesAssigned: $timesAssigned, '
        'totalExercises: $totalExercises, '
        'dayBreakdown: $dayBreakdown, '
        'createdAt: $createdAt, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is WorkoutTemplateMiniEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
