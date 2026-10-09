import 'member_manager_entities.dart';

class MembershipPlanMiniEntity {
  final String id;
  final String name;
  final num durationDays;
  final num price;
  final String description;
  final List<String> features;
  final List<PlanOfferEntity> offers;
  final bool isActive;

  const MembershipPlanMiniEntity({
    this.id = '',
    this.name = '',
    this.durationDays = 0,
    this.price = 0,
    this.description = '',
    this.features = const [],
    this.offers = const [],
    this.isActive = false,
  });

  MembershipPlanMiniEntity copyWith({
    String? id,
    String? name,
    num? durationDays,
    num? price,
    String? description,
    List<String>? features,
    bool? isActive,
  }) => MembershipPlanMiniEntity(
    id: id ?? this.id,
    name: name ?? this.name,
    durationDays: durationDays ?? this.durationDays,
    price: price ?? this.price,
    description: description ?? this.description,
    features: features ?? this.features,
    isActive: isActive ?? this.isActive,
  );

  @override
  String toString() {
    return 'MembershipPlanMiniEntity('
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
        (other is MembershipPlanMiniEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
