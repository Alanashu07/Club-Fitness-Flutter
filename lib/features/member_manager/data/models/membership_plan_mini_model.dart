import '../../domain/entities/membership_plan_mini_entity.dart';

class MembershipPlanMiniModel extends MembershipPlanMiniEntity {
  const MembershipPlanMiniModel({
    super.id,
    super.name,
    super.durationDays,
    super.price,
    super.description,
    super.features,
    super.isActive,
  });

  factory MembershipPlanMiniModel.fromJson(Map<String, dynamic> json) {
    return MembershipPlanMiniModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      durationDays: json['durationDays'] as num? ?? 0,
      price: json['price'] as num? ?? 0,
      description: json['description'] as String? ?? '',
      features: (json['features'] as List?)?.cast<String>() ?? const [],
      isActive: json['isActive'] as bool? ?? false,
    );
  }

  factory MembershipPlanMiniModel.fromEntity(MembershipPlanMiniEntity entity) {
    return MembershipPlanMiniModel(
      id: entity.id,
      name: entity.name,
      durationDays: entity.durationDays,
      price: entity.price,
      description: entity.description,
      features: entity.features,
      isActive: entity.isActive,
    );
  }

  @override
  MembershipPlanMiniModel copyWith({
    String? id,
    String? name,
    num? durationDays,
    num? price,
    String? description,
    List<String>? features,
    bool? isActive,
  }) => MembershipPlanMiniModel(
    id: id ?? this.id,
    name: name ?? this.name,
    durationDays: durationDays ?? this.durationDays,
    price: price ?? this.price,
    description: description ?? this.description,
    features: features ?? this.features,
    isActive: isActive ?? this.isActive,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'durationDays': durationDays,
    'price': price,
    'description': description,
    'features': features,
    'isActive': isActive,
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'MembershipPlanMiniModel('
        'id: $id, '
        'name: $name, '
        'durationDays: $durationDays, '
        'price: $price, '
        'description: $description, '
        'features: $features, '
        'isActive: $isActive, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other is MembershipPlanMiniModel && other.id == id);
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}
