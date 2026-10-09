class RenewResult {
  final String planId;
  final String? startOverride;
  final double? paidAmount;
  final String? paymentMethod;
  final String? notes;
  final String? receiptPath;
  final bool waiveRemaining;
  final String? offerId;
  final String? offerCode;
  final String planName, startDate, endDate;
  final num planPrice, paidPrice;

  const RenewResult({
    required this.planId,
    required this.planName,
    required this.startDate,
    required this.endDate,
    this.startOverride,
    this.paidAmount,
    this.paymentMethod,
    this.notes,
    this.receiptPath,
    this.waiveRemaining = false,
    this.offerId,
    this.offerCode,
    required this.planPrice,
    required this.paidPrice,
  });
}