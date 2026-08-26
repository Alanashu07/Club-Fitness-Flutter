import 'package:club_fitness/core/entities/pagination_entity.dart';
import 'admin_utils_entities.dart';

class FeeResponseEntity {
  final List<FeesEntity> fees;
  final PaginationEntity pagination;
  final CountsEntity counts;

  const FeeResponseEntity({
    this.fees = const [],
    this.pagination = const PaginationEntity(),
    this.counts = const CountsEntity(),
  });

  @override
  String toString() {
    return 'FeeResponseEntity('
      'fees: $fees, '
      'pagination: $pagination, '
      'counts: $counts, '
    ')';
  }
}

