import 'package:club_fitness/core/models/id_name_model.dart';
import 'package:club_fitness/core/utils/common_functions.dart';

import '../../domain/entities/offer_entity.dart';

class OfferModel extends OfferEntity {
  const OfferModel({
    super.id,
    super.name,
    super.code,
    super.description,
    super.discountType,
    super.discountValue,
    super.maxDiscountAmount,
    super.appliesTo,
    super.appliesToAllPlans,
    super.validFrom,
    super.validUntil,
    super.maxRedemptions,
    super.perUserLimit,
    super.redemptionCount,
    super.isActive,
    super.createdAt,
    super.updatedAt,
    super.plans,
  });

  factory OfferModel.fromJson(Map<String, dynamic> json) {
    return OfferModel(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      code: json['code'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountType: json['discountType'] as String? ?? '',
      discountValue: json['discountValue'] as String? ?? '',
      maxDiscountAmount: json['maxDiscountAmount']?.toString().toNum ?? 0,
      appliesTo: json['appliesTo'] as String? ?? '',
      appliesToAllPlans: json['appliesToAllPlans'] as bool? ?? false,
      validFrom: json['validFrom'] as String? ?? '',
      validUntil: json['validUntil'] as String? ?? '',
      maxRedemptions: json['maxRedemptions']?.toString().toNum ?? 0,
      perUserLimit: json['perUserLimit'] as num? ?? 0,
      redemptionCount: json['redemptionCount'] as num? ?? 0,
      isActive: json['isActive'] as bool? ?? false,
      createdAt: json['createdAt'] as String? ?? '',
      updatedAt: json['updatedAt'] as String? ?? '',
      plans:
          (json['plans'] as List?)
              ?.map((e) => IdNameModel.fromJson(e))
              .toList() ??
          const [],
    );
  }

  factory OfferModel.fromEntity(OfferEntity entity) {
    return OfferModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      description: entity.description,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      maxDiscountAmount: entity.maxDiscountAmount,
      appliesTo: entity.appliesTo,
      appliesToAllPlans: entity.appliesToAllPlans,
      validFrom: entity.validFrom,
      validUntil: entity.validUntil,
      maxRedemptions: entity.maxRedemptions,
      perUserLimit: entity.perUserLimit,
      redemptionCount: entity.redemptionCount,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
      plans: entity.plans,
    );
  }

  OfferModel copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? discountType,
    String? discountValue,
    num? maxDiscountAmount,
    String? appliesTo,
    bool? appliesToAllPlans,
    String? validFrom,
    String? validUntil,
    num? maxRedemptions,
    num? perUserLimit,
    num? redemptionCount,
    bool? isActive,
    String? createdAt,
    String? updatedAt,
    List<IdNameModel>? plans,
  }) => OfferModel(
    id: id ?? this.id,
    name: name ?? this.name,
    code: code ?? this.code,
    description: description ?? this.description,
    discountType: discountType ?? this.discountType,
    discountValue: discountValue ?? this.discountValue,
    maxDiscountAmount: maxDiscountAmount ?? this.maxDiscountAmount,
    appliesTo: appliesTo ?? this.appliesTo,
    appliesToAllPlans: appliesToAllPlans ?? this.appliesToAllPlans,
    validFrom: validFrom ?? this.validFrom,
    validUntil: validUntil ?? this.validUntil,
    maxRedemptions: maxRedemptions ?? this.maxRedemptions,
    perUserLimit: perUserLimit ?? this.perUserLimit,
    redemptionCount: redemptionCount ?? this.redemptionCount,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    plans: plans ?? this.plans,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'code': code,
    'description': description,
    'discountType': discountType,
    'discountValue': discountValue,
    'maxDiscountAmount': maxDiscountAmount,
    'appliesTo': appliesTo,
    'appliesToAllPlans': appliesToAllPlans,
    'validFrom': validFrom,
    'validUntil': validUntil,
    'maxRedemptions': maxRedemptions,
    'perUserLimit': perUserLimit,
    'redemptionCount': redemptionCount,
    'isActive': isActive,
    'createdAt': createdAt,
    'updatedAt': updatedAt,
    'plans': plans.map((e) => IdNameModel.fromEntity(e).toJson()).toList(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'OfferModel('
        'id: $id, '
        'name: $name, '
        'code: $code, '
        'description: $description, '
        'discountType: $discountType, '
        'discountValue: $discountValue, '
        'maxDiscountAmount: $maxDiscountAmount, '
        'appliesTo: $appliesTo, '
        'appliesToAllPlans: $appliesToAllPlans, '
        'validFrom: $validFrom, '
        'validUntil: $validUntil, '
        'maxRedemptions: $maxRedemptions, '
        'perUserLimit: $perUserLimit, '
        'redemptionCount: $redemptionCount, '
        'isActive: $isActive, '
        'createdAt: $createdAt, '
        'updatedAt: $updatedAt, '
        'plans: $plans, '
        ')';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) || (other is OfferModel && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;

  // Helper function to remove empty or default values from JSON
  bool _removeEmpty(dynamic value) {
    if (value == null) return true;
    if (value is num) return value == 0;
    if (value is String) return value.isEmpty;
    if (value is List) return value.isEmpty;
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}
