import '../../domain/entities/plan_listing_entity.dart';
import 'workout_manager_models.dart';

class CountModel extends CountEntity {
  const CountModel({
    super.assignments,
    super.days,
  });

  factory CountModel.fromJson(Map<String, dynamic> json) {
    return CountModel(
      assignments: json['assignments'] as num? ?? 0,
      days: json['days'] as num? ?? 0,
    );
  }

  factory CountModel.fromEntity(CountEntity entity) {
    return CountModel(
      assignments: entity.assignments,
      days: entity.days,
    );
  }

  CountModel copyWith({
    num? assignments,
    num? days,
  }) => CountModel(
      assignments: assignments ?? this.assignments,
      days: days ?? this.days,
  );

  Map<String, dynamic> toJson() => {
        'assignments': assignments,
        'days': days,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'CountModel('
      'assignments: $assignments, '
      'days: $days, '
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

class PlanListingModel extends PlanListingEntity {
  const PlanListingModel({
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
    super.count,
  });

  factory PlanListingModel.fromJson(Map<String, dynamic> json) {
    return PlanListingModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      isTemplate: json['isTemplate'] as bool? ?? false,
      createdById: json['createdById'] as String? ?? '',
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      createdBy: json['createdBy'] != null ? CreatedByModel.fromJson(json['createdBy']) : const CreatedByModel(),
      count: json['_count'] != null ? CountModel.fromJson(json['_count']) : const CountModel(),
    );
  }

  factory PlanListingModel.fromEntity(PlanListingEntity entity) {
    return PlanListingModel(
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
      count: entity.count,
    );
  }

  PlanListingModel copyWith({
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
    CountModel? count,
  }) => PlanListingModel(
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
        '_count': CountModel.fromEntity(count).toJson(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'PlanListingModel('
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
    return identical(this, other) || (other is PlanListingModel && other.id == id);
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

