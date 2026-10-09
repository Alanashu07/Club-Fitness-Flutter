
import '../../domain/entities/plan_offer_entity.dart';

class PlanOfferModel extends PlanOfferEntity {
  const PlanOfferModel({
    super.id,
    super.name,
    super.code,
    super.discountAmount,
    super.finalAmount,
  });

  factory PlanOfferModel.fromJson(Map<String, dynamic> json) {
    return PlanOfferModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      discountAmount: json['discountAmount'] as num? ?? 0,
      finalAmount: json['finalAmount'] as num? ?? 0,
    );
  }

  factory PlanOfferModel.fromEntity(PlanOfferEntity entity) {
    return PlanOfferModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      discountAmount: entity.discountAmount,
      finalAmount: entity.finalAmount,
    );
  }

  PlanOfferModel copyWith({
    String? id,
    String? name,
    String? code,
    num? discountAmount,
    num? finalAmount,
  }) => PlanOfferModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      discountAmount: discountAmount ?? this.discountAmount,
      finalAmount: finalAmount ?? this.finalAmount,
  );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'code': code,
        'discountAmount': discountAmount,
        'finalAmount': finalAmount,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'PlanOfferModel('
      'id: $id, '
      'name: $name, '
      'code: $code, '
      'discountAmount: $discountAmount, '
      'finalAmount: $finalAmount, '
    ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is PlanOfferModel && other.id == id);
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

