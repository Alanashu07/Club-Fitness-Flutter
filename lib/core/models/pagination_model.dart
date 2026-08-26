import 'package:club_fitness/core/entities/pagination_entity.dart';

class PaginationModel extends PaginationEntity {
  const PaginationModel({
    super.limit,
    super.page,
    super.total,
    super.totalPages,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) =>
      PaginationModel(
        limit: json['limit'],
        page: json['page'],
        total: json['total'],
        totalPages: json['totalPages'],
      );

  factory PaginationModel.fromEntity(PaginationEntity entity) =>
      PaginationModel(
        limit: entity.limit,
        page: entity.page,
        total: entity.total,
        totalPages: entity.totalPages,
      );

  Map<String, dynamic> toJson() => {
    'limit': limit,
    'page': page,
    'total': total,
    'totalPages': totalPages,
  };

  PaginationModel copyWith({
    int? limit,
    int? page,
    int? total,
    int? totalPages,
  }) => PaginationModel(
    limit: limit ?? this.limit,
    page: page ?? this.page,
    total: total ?? this.total,
    totalPages: totalPages ?? this.totalPages,
  );
}

class ResponseModel<T> extends ResponseEntity<T> {
  const ResponseModel({super.data, super.pagination});

  factory ResponseModel.fromJson(
    Map<String, dynamic> json, {
    String key = 'data',
    required T Function(Map<String, dynamic> json) fromJson,
  }) => ResponseModel(
    data: (json[key] as List?)?.map((e) => fromJson(e)).toList() ?? [],
    pagination: PaginationModel.fromJson(json['pagination'] ?? {}),
  );

  factory ResponseModel.fromEntity(ResponseEntity<T> entity) => ResponseModel(
    data: entity.data,
    pagination: PaginationModel.fromEntity(entity.pagination),
  );

  Map<String, dynamic> toJson(
    Map<String, dynamic> Function(T data) toJson, {
    String key = 'data',
  }) => {
    key: data.map((e) => toJson(e)).toList(),
    'pagination': PaginationModel.fromEntity(pagination).toJson(),
  };

  ResponseEntity<T> copyWith({
    List<T>? data,
    PaginationEntity? pagination,
  }) => ResponseEntity(
    data: data ?? this.data,
    pagination: pagination ?? this.pagination,
  );
}
