import 'workout_manager_entities.dart';

class CountEntity {
  final num assignments;
  final num days;

  const CountEntity({this.assignments = 0, this.days = 0});

  @override
  String toString() {
    return 'CountEntity('
        'assignments: $assignments, '
        'days: $days, '
        ')';
  }
}

class PlanListingEntity {
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
  final CountEntity count;

  const PlanListingEntity({
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
    this.count = const CountEntity(),
  });

  @override
  String toString() {
    return 'PlanListingEntity('
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
        'Count: $count, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is PlanListingEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
