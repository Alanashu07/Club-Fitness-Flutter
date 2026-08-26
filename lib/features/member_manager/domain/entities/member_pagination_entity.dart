import 'member_manager_entities.dart';

class MemberPaginationEntity {
  final List<MemberListEntity> members;
  final Pagination pagination;
  final Summary summary;

  const MemberPaginationEntity({
    this.members = const [],
    this.pagination = const Pagination(),
    this.summary = const Summary(),
  });
}

class Pagination {
  final num page;
  final num limit;
  final num totalPages;
  final num total;

  const Pagination({
    this.page = 0,
    this.limit = 0,
    this.totalPages = 0,
    this.total = 0,
  });

  num get nextPage => page + 1;
  bool get hasNextPage => page < totalPages;
}

class Summary {
  final num total;
  final num active;
  final num expired;
  final num overdue;

  const Summary({
    this.total = 0,
    this.active = 0,
    this.expired = 0,
    this.overdue = 0,
  });
}
