class SummaryCountsEntity {
  final num total;
  final num pending;
  final num overdue;
  final num paid;
  final num partial;
  final num waived;

  const SummaryCountsEntity({
    this.total = 0,
    this.pending = 0,
    this.overdue = 0,
    this.paid = 0,
    this.partial = 0,
    this.waived = 0,
  });

  @override
  String toString() {
    return 'SummaryCountsEntity('
      'total: $total, '
      'pending: $pending, '
      'overdue: $overdue, '
      'paid: $paid, '
      'partial: $partial, '
      'waived: $waived, '
    ')';
  }
}

class FeeSummaryEntity {
  final num totalCollected;
  final num totalOutstanding;
  final num totalPartialPaid;
  final num collectedProgress;
  final SummaryCountsEntity counts;

  const FeeSummaryEntity({
    this.totalCollected = 0,
    this.totalOutstanding = 0,
    this.totalPartialPaid = 0,
    this.collectedProgress = 0,
    this.counts = const SummaryCountsEntity(),
  });

  @override
  String toString() {
    return 'FeeSummaryEntity('
      'totalCollected: $totalCollected, '
      'totalOutstanding: $totalOutstanding, '
      'totalPartialPaid: $totalPartialPaid, '
      'collectedProgress: $collectedProgress, '
      'counts: $counts, '
    ')';
  }
}

