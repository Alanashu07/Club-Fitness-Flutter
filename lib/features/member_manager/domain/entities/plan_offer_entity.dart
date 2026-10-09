class PlanOfferEntity {
  final String id;
  final String name;
  final String code;
  final num discountAmount;
  final num finalAmount;

  const PlanOfferEntity({
    this.id = '',
    this.name = '',
    this.code = '',
    this.discountAmount = 0,
    this.finalAmount = 0,
  });

  @override
  String toString() {
    return 'PlanOfferEntity('
      'id: $id, '
      'name: $name, '
      'code: $code, '
      'discountAmount: $discountAmount, '
      'finalAmount: $finalAmount, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PlanOfferEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}
