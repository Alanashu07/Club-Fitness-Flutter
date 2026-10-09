class OfferRedemptionEntity {
  final String offerName;
  final String offerCode;
  final String redeemedAt;

  const OfferRedemptionEntity({
    this.offerName = '',
    this.offerCode = '',
    this.redeemedAt = '',
  });

  @override
  String toString() {
    return 'OfferRedemptionEntity('
      'offerName: $offerName, '
      'offerCode: $offerCode, '
      'redeemedAt: $redeemedAt, '
    ')';
  }
}
