class PaginationEntity {
  final num page;
  final num limit;
  final num total;
  final num totalPages;

  const PaginationEntity({
    this.page = 0,
    this.limit = 0,
    this.total = 0,
    this.totalPages = 0,
  });

  @override
  String toString() {
    return 'Page No: $page, Items per page: $limit, Total: $total, Total pages: $totalPages';
  }
  
  num get nextPage => page + 1;
  bool get hasNextPage => page < totalPages;
}

class ResponseEntity<T> {
  final List<T> data;
  final PaginationEntity pagination;

  const ResponseEntity({
    this.data = const [],
    this.pagination = const PaginationEntity(),
  });
}
