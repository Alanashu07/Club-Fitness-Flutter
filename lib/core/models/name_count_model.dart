import '../entities/name_count_entity.dart';

class NameCountModel extends NameCountEntity {
  const NameCountModel({
    super.name,
    super.count,
  });

  factory NameCountModel.fromJson(Map<String, dynamic> json) {
    return NameCountModel(
      name: json['name'] as String? ?? '',
      count: json['count'] as num? ?? 0,
    );
  }

  factory NameCountModel.fromEntity(NameCountEntity entity) {
    return NameCountModel(
      name: entity.name,
      count: entity.count,
    );
  }

  NameCountModel copyWith({
    String? name,
    num? count,
  }) => NameCountModel(
      name: name ?? this.name,
      count: count ?? this.count,
  );

  Map<String, dynamic> toJson() => {
        'name': name,
        'count': count,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'NameCountModel('
      'name: $name, '
      'count: $count, '
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

