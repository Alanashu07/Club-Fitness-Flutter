import 'package:club_fitness/core/models/pagination_model.dart';

import '../../domain/entities/fee_response_entity.dart';
import 'admin_utils_models.dart';

class FeeResponseModel extends FeeResponseEntity {
  const FeeResponseModel({super.fees, super.pagination, super.counts});

  factory FeeResponseModel.fromJson(Map<String, dynamic> json) {
    return FeeResponseModel(
      fees:
          (json['fees'] as List?)?.map((e) => FeesModel.fromJson(e)).toList() ??
          const [],
      pagination: json['pagination'] != null
          ? PaginationModel.fromJson(json['pagination'])
          : const PaginationModel(),
      counts: json['counts'] != null
          ? CountsModel.fromJson(json['counts'])
          : const CountsModel(),
    );
  }

  factory FeeResponseModel.fromEntity(FeeResponseEntity entity) {
    return FeeResponseModel(
      fees: entity.fees,
      pagination: entity.pagination,
      counts: entity.counts,
    );
  }

  FeeResponseModel copyWith({
    List<FeesModel>? fees,
    PaginationModel? pagination,
    CountsModel? counts,
  }) => FeeResponseModel(
    fees: fees ?? this.fees,
    pagination: pagination ?? this.pagination,
    counts: counts ?? this.counts,
  );

  Map<String, dynamic> toJson() => {
    'fees': fees.map((e) => FeesModel.fromEntity(e).toJson()).toList(),
    'pagination': PaginationModel.fromEntity(pagination).toJson(),
    'counts': CountsModel.fromEntity(counts).toJson(),
  }..removeWhere((key, value) => _removeEmpty(value));

  @override
  String toString() {
    return 'FeeResponseModel('
        'fees: $fees, '
        'pagination: $pagination, '
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
    if (value is Map) {
      return (value..removeWhere((key, value) => _removeEmpty(value))).isEmpty;
    }
    return false;
  }
}
