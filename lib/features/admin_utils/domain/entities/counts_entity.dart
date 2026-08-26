class CountsEntity {
  final num all;
  final num pending;
  final num overdue;
  final num paid;
  final num partial;
  final num waived;

  const CountsEntity({
    this.all = 0,
    this.pending = 0,
    this.overdue = 0,
    this.paid = 0,
    this.partial = 0,
    this.waived = 0,
  });

  @override
  String toString() {
    return 'CountsEntity('
      'all: $all, '
      'pending: $pending, '
      'overdue: $overdue, '
      'paid: $paid, '
      'partial: $partial, '
      'waived: $waived, '
    ')';
  }
}