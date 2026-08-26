import '../../domain/entities/workout_template_mini_entity.dart';
import 'workout_manager_models.dart';

class DayBreakdowModel extends DayBreakdowEntity {
  const DayBreakdowModel({
    super.day,
    super.isRestDay,
    super.exerciseCount,
  });

  factory DayBreakdowModel.fromJson(Map<String, dynamic> json) {
    return DayBreakdowModel(
      day: json['day'] as String? ?? '',
      isRestDay: json['isRestDay'] as bool? ?? false,
      exerciseCount: json['exerciseCount'] as num? ?? 0,
    );
  }

  factory DayBreakdowModel.fromEntity(DayBreakdowEntity entity) {
    return DayBreakdowModel(
      day: entity.day,
      isRestDay: entity.isRestDay,
      exerciseCount: entity.exerciseCount,
    );
  }

  DayBreakdowModel copyWith({
    String? day,
    bool? isRestDay,
    num? exerciseCount,
  }) => DayBreakdowModel(
      day: day ?? this.day,
      isRestDay: isRestDay ?? this.isRestDay,
      exerciseCount: exerciseCount ?? this.exerciseCount,
  );

  Map<String, dynamic> toJson() => {
        'day': day,
        'isRestDay': isRestDay,
        'exerciseCount': exerciseCount,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'DayBreakdowModel('
      'day: $day, '
      'isRestDay: $isRestDay, '
      'exerciseCount: $exerciseCount, '
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

class WorkoutTemplateMiniModel extends WorkoutTemplateMiniEntity {
  const WorkoutTemplateMiniModel({
    super.id,
    super.name,
    super.type,
    super.createdBy,
    super.startDate,
    super.endDate,
    super.timesAssigned,
    super.totalExercises,
    super.dayBreakdown,
    super.createdAt,
  });

  factory WorkoutTemplateMiniModel.fromJson(Map<String, dynamic> json) {
    return WorkoutTemplateMiniModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      type: json['type'] as String? ?? '',
      createdBy: json['createdBy'] != null ? CreatedByModel.fromJson(json['createdBy']) : const CreatedByModel(),
      startDate: json['startDate'] as String? ?? '',
      endDate: json['endDate'] as String? ?? '',
      timesAssigned: json['timesAssigned'] as num? ?? 0,
      totalExercises: json['totalExercises'] as num? ?? 0,
      dayBreakdown: (json['dayBreakdown'] as List?)?.map((e) => DayBreakdowModel.fromJson(e)).toList() ?? const [],
      createdAt: json['createdAt'] as String? ?? '',
    );
  }

  factory WorkoutTemplateMiniModel.fromEntity(WorkoutTemplateMiniEntity entity) {
    return WorkoutTemplateMiniModel(
      id: entity.id,
      name: entity.name,
      type: entity.type,
      createdBy: entity.createdBy,
      startDate: entity.startDate,
      endDate: entity.endDate,
      timesAssigned: entity.timesAssigned,
      totalExercises: entity.totalExercises,
      dayBreakdown: entity.dayBreakdown,
      createdAt: entity.createdAt,
    );
  }

  WorkoutTemplateMiniModel copyWith({
    String? id,
    String? name,
    String? type,
    CreatedByModel? createdBy,
    String? startDate,
    String? endDate,
    num? timesAssigned,
    num? totalExercises,
    List<DayBreakdowModel>? dayBreakdown,
    String? createdAt,
  }) => WorkoutTemplateMiniModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      createdBy: createdBy ?? this.createdBy,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      timesAssigned: timesAssigned ?? this.timesAssigned,
      totalExercises: totalExercises ?? this.totalExercises,
      dayBreakdown: dayBreakdown ?? this.dayBreakdown,
      createdAt: createdAt ?? this.createdAt,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'type': type,
        'createdBy': CreatedByModel.fromEntity(createdBy).toJson(),
        'startDate': startDate,
        'endDate': endDate,
        'timesAssigned': timesAssigned,
        'totalExercises': totalExercises,
        'dayBreakdown': dayBreakdown.map((e) => DayBreakdowModel.fromEntity(e).toJson()).toList(),
        'createdAt': createdAt,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'WorkoutTemplateMiniModel('
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
    return identical(this, other) || (other is WorkoutTemplateMiniModel && other.id == id);
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

