
import '../../domain/entities/offer_redemption_entity.dart';

class OfferRedemptionModel extends OfferRedemptionEntity {
  const OfferRedemptionModel({
    super.offerName,
    super.offerCode,
    super.redeemedAt,
  });

  factory OfferRedemptionModel.fromJson(Map<String, dynamic> json) {
    return OfferRedemptionModel(
      offerName: json['offerName'] as String? ?? '',
      offerCode: json['offerCode'] as String? ?? '',
      redeemedAt: json['redeemedAt'] as String? ?? '',
    );
  }

  factory OfferRedemptionModel.fromEntity(OfferRedemptionEntity entity) {
    return OfferRedemptionModel(
      offerName: entity.offerName,
      offerCode: entity.offerCode,
      redeemedAt: entity.redeemedAt,
    );
  }

  OfferRedemptionModel copyWith({
    String? offerName,
    String? offerCode,
    String? redeemedAt,
  }) => OfferRedemptionModel(
      offerName: offerName ?? this.offerName,
      offerCode: offerCode ?? this.offerCode,
      redeemedAt: redeemedAt ?? this.redeemedAt,
  );

  Map<String, dynamic> toJson() => {
        'offerName': offerName,
        'offerCode': offerCode,
        'redeemedAt': redeemedAt,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'OfferRedemptionModel('
      'offerName: $offerName, '
      'offerCode: $offerCode, '
      'redeemedAt: $redeemedAt, '
    ')';
  }

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

