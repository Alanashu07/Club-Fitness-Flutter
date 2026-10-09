import 'package:club_fitness/core/entities/id_name_entity.dart';

import 'offers_entities.dart';

class OfferEntity {
  final String id;
  final String name;
  final String code;
  final String description;
  final String discountType;
  final String discountValue;
  final num maxDiscountAmount;
  final String appliesTo;
  final bool appliesToAllPlans;
  final String validFrom;
  final String validUntil;
  final num maxRedemptions;
  final num perUserLimit;
  final num redemptionCount;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final List<IdNameEntity> plans;

  const OfferEntity({
    this.id = '',
    this.name = '',
    this.code = '',
    this.description = '',
    this.discountType = '',
    this.discountValue = '',
    this.maxDiscountAmount = 0,
    this.appliesTo = '',
    this.appliesToAllPlans = false,
    this.validFrom = '',
    this.validUntil = '',
    this.maxRedemptions = 0,
    this.perUserLimit = 0,
    this.redemptionCount = 0,
    this.isActive = false,
    this.createdAt = '',
    this.updatedAt = '',
    this.plans = const [],
  });

  @override
  String toString() {
    return 'OfferEntity('
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
    return identical(this, other) || (other is OfferEntity && other.id == id);
  }

  @override
  int get hashCode => id.hashCode;
}

extension OfferExtension on OfferEntity {
  bool get isPercentage => discountType == 'PERCENTAGE';
  DateTime? get validUntilDate => DateTime.tryParse(validUntil);
  DateTime? get validFromDate => DateTime.tryParse(validFrom);

  OfferLifecycle get lifecycle {
    final now = DateTime.now();
    if (!isActive) return OfferLifecycle.inactive;
    if (validUntilDate != null && validUntilDate!.isBefore(now)) {
      return OfferLifecycle.expired;
    }
    if (validFromDate != null && validFromDate!.isAfter(now)) {
      return OfferLifecycle.scheduled;
    }
    return OfferLifecycle.active;
  }
}
