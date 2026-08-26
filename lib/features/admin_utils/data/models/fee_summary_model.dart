import '../../domain/entities/fee_summary_entity.dart';

class SummaryCountsModel extends SummaryCountsEntity {
  const SummaryCountsModel({
    super.total,
    super.pending,
    super.overdue,
    super.paid,
    super.partial,
    super.waived,
  });

  factory SummaryCountsModel.fromJson(Map<String, dynamic> json) {
    return SummaryCountsModel(
      total: json['total'] as num? ?? 0,
      pending: json['pending'] as num? ?? 0,
      overdue: json['overdue'] as num? ?? 0,
      paid: json['paid'] as num? ?? 0,
      partial: json['partial'] as num? ?? 0,
      waived: json['waived'] as num? ?? 0,
    );
  }

  factory SummaryCountsModel.fromEntity(SummaryCountsEntity entity) {
    return SummaryCountsModel(
      total: entity.total,
      pending: entity.pending,
      overdue: entity.overdue,
      paid: entity.paid,
      partial: entity.partial,
      waived: entity.waived,
    );
  }

  SummaryCountsModel copyWith({
    num? total,
    num? pending,
    num? overdue,
    num? paid,
    num? partial,
    num? waived,
  }) => SummaryCountsModel(
      total: total ?? this.total,
      pending: pending ?? this.pending,
      overdue: overdue ?? this.overdue,
      paid: paid ?? this.paid,
      partial: partial ?? this.partial,
      waived: waived ?? this.waived,
  );

  Map<String, dynamic> toJson() => {
        'total': total,
        'pending': pending,
        'overdue': overdue,
        'paid': paid,
        'partial': partial,
        'waived': waived,
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'SummaryCountsModel('
      'total: $total, '
      'pending: $pending, '
      'overdue: $overdue, '
      'paid: $paid, '
      'partial: $partial, '
      'waived: $waived, '
    ')';
  }

  // Helper function to remove empty values
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

class FeeSummaryModel extends FeeSummaryEntity {
  const FeeSummaryModel({
    super.totalCollected,
    super.totalOutstanding,
    super.totalPartialPaid,
    super.collectedProgress,
    super.counts,
  });

  factory FeeSummaryModel.fromJson(Map<String, dynamic> json) {
    return FeeSummaryModel(
      totalCollected: json['totalCollected'] as num? ?? 0,
      totalOutstanding: json['totalOutstanding'] as num? ?? 0,
      totalPartialPaid: json['totalPartialPaid'] as num? ?? 0,
      collectedProgress: json['collectedProgress'] as num? ?? 0,
      counts: json['counts'] != null ? SummaryCountsModel.fromJson(json['counts']) : const SummaryCountsModel(),
    );
  }

  factory FeeSummaryModel.fromEntity(FeeSummaryEntity entity) {
    return FeeSummaryModel(
      totalCollected: entity.totalCollected,
      totalOutstanding: entity.totalOutstanding,
      totalPartialPaid: entity.totalPartialPaid,
      collectedProgress: entity.collectedProgress,
      counts: entity.counts,
    );
  }

  FeeSummaryModel copyWith({
    num? totalCollected,
    num? totalOutstanding,
    num? totalPartialPaid,
    num? collectedProgress,
    SummaryCountsModel? counts,
  }) => FeeSummaryModel(
      totalCollected: totalCollected ?? this.totalCollected,
      totalOutstanding: totalOutstanding ?? this.totalOutstanding,
      totalPartialPaid: totalPartialPaid ?? this.totalPartialPaid,
      collectedProgress: collectedProgress ?? this.collectedProgress,
      counts: counts ?? this.counts,
  );

  Map<String, dynamic> toJson() => {
        'totalCollected': totalCollected,
        'totalOutstanding': totalOutstanding,
        'totalPartialPaid': totalPartialPaid,
        'collectedProgress': collectedProgress,
        'counts': SummaryCountsModel.fromEntity(counts).toJson(),
      }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'FeeSummaryModel('
      'totalCollected: $totalCollected, '
      'totalOutstanding: $totalOutstanding, '
      'totalPartialPaid: $totalPartialPaid, '
      'collectedProgress: $collectedProgress, '
      'counts: $counts, '
    ')';
  }

  // Helper function to remove empty values
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

