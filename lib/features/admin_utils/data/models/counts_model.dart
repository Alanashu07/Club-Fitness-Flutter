import '../../domain/entities/counts_entity.dart';

class CountsModel extends CountsEntity {
  const CountsModel({
    super.all,
    super.pending,
    super.overdue,
    super.paid,
    super.partial,
    super.waived,
  });

  factory CountsModel.fromJson(Map<String, dynamic> json) {
    return CountsModel(
      all: json['all'] as num? ?? 0,
      pending: json['pending'] as num? ?? 0,
      overdue: json['overdue'] as num? ?? 0,
      paid: json['paid'] as num? ?? 0,
      partial: json['partial'] as num? ?? 0,
      waived: json['waived'] as num? ?? 0,
    );
  }

  factory CountsModel.fromEntity(CountsEntity entity) {
    return CountsModel(
      all: entity.all,
      pending: entity.pending,
      overdue: entity.overdue,
      paid: entity.paid,
      partial: entity.partial,
      waived: entity.waived,
    );
  }

  CountsModel copyWith({
    num? all,
    num? pending,
    num? overdue,
    num? paid,
    num? partial,
    num? waived,
  }) => CountsModel(
    all: all ?? this.all,
    pending: pending ?? this.pending,
    overdue: overdue ?? this.overdue,
    paid: paid ?? this.paid,
    partial: partial ?? this.partial,
    waived: waived ?? this.waived,
  );

  Map<String, dynamic> toJson() => {
    'all': all,
    'pending': pending,
    'overdue': overdue,
    'paid': paid,
    'partial': partial,
    'waived': waived,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'CountsModel('
        'all: $all, '
        'pending: $pending, '
        'overdue: $overdue, '
        'paid: $paid, '
        'partial: $partial, '
        'waived: $waived, '
        ')';
  }

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