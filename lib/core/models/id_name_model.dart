
import '../entities/id_name_entity.dart';

class IdNameModel extends IdNameEntity {
  const IdNameModel({
    super.id,
    super.name,
  });

  factory IdNameModel.fromJson(Map<String, dynamic> json) {
    return IdNameModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
    );
  }

  factory IdNameModel.fromEntity(IdNameEntity entity) {
    return IdNameModel(
      id: entity.id,
      name: entity.name,
    );
  }

  IdNameModel copyWith({
    String? id,
    String? name,
  }) => IdNameModel(
      id: id ?? this.id,
      name: name ?? this.name,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'IdNameModel('
      'id: $id, '
      'name: $name, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is IdNameModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

// Helper function to remove empty or default values from JSON
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

