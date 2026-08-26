import '../../domain/entities/member_manager_entities.dart';
import 'member_manager_models.dart';

class MemberPaginationModel extends MemberPaginationEntity {
  const MemberPaginationModel({
    super.members,
    super.pagination,
    super.summary,
  });

  factory MemberPaginationModel.fromJson(Map<String, dynamic> json) {
    return MemberPaginationModel(
      members: (json['members'] as List<dynamic>?)
              ?.map((e) => MemberListModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: PaginationModel.fromJson(
          json['pagination'] as Map<String, dynamic>? ?? {}),
      summary: SummaryModel.fromJson(
          json['summary'] as Map<String, dynamic>? ?? {}),
    );
  }

  factory MemberPaginationModel.fromEntity(MemberPaginationEntity entity) {
    return MemberPaginationModel(
      members: entity.members
          .map((e) => MemberListModel.fromEntity(e))
          .toList(),
      pagination: PaginationModel(
        page: entity.pagination.page,
        limit: entity.pagination.limit,
        totalPages: entity.pagination.totalPages,
        total: entity.pagination.total,
      ),
      summary: SummaryModel(
        total: entity.summary.total,
        active: entity.summary.active,
        expired: entity.summary.expired,
        overdue: entity.summary.overdue,
      ),
    );
  }
}

class PaginationModel extends Pagination {
  const PaginationModel({
    super.page,
    super.limit,
    super.totalPages,
    super.total,
  });

  factory PaginationModel.fromJson(Map<String, dynamic> json) {
    return PaginationModel(
      page: json['page'] as num? ?? 0,
      limit: json['limit'] as num? ?? 0,
      totalPages: json['totalPages'] as num? ?? 0,
      total: json['total'] as num? ?? 0,
    );
  }
}

class SummaryModel extends Summary {
  const SummaryModel({
    super.total,
    super.active,
    super.expired,
    super.overdue,
  });

  factory SummaryModel.fromJson(Map<String, dynamic> json) {
    return SummaryModel(
      total: json['total'] as num? ?? 0,
      active: json['active'] as num? ?? 0,
      expired: json['expired'] as num? ?? 0,
      overdue: json['overdue'] as num? ?? 0,
    );
  }
}