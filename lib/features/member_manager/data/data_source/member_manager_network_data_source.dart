import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/core/utils/utils.dart';

import '../models/member_manager_models.dart';

abstract interface class MemberManagerNetworkDataSource {
  Future<MemberPaginationModel> getMemberList({
    String search,
    String status,
    String? plan,
    String? trainer,
    bool checkedInToday,
    bool overdueOnly,
    String sortBy,
    String page,
    String limit,
  });
  Future<MemberListModel> createMember({
    required String name,
    required String phone,
    required String email,
    required String plan,
    required String trainer,
    required String dob,
    required String startDate,
  });
  Future<List<TrainerMiniModel>> getTrainers();
  Future<List<MembershipPlanMiniModel>> getPlans(bool includeInactive);
  Future<MembershipPlanMiniModel> createMembershipPlan(MembershipPlanMiniModel model);
  Future<MembershipPlanMiniModel> updateMembershipPlan(MembershipPlanMiniModel model);
  Future<bool> deleteMembershipPlan(String id);
}

class MemberManagerNetworkDataSourceImpl
    implements MemberManagerNetworkDataSource {
  final DioConfig _dio;
  const MemberManagerNetworkDataSourceImpl(this._dio);
  @override
  Future<MemberPaginationModel> getMemberList({
    String search = '',
    String status = '',
    String? plan,
    String? trainer,
    bool checkedInToday = false,
    bool overdueOnly = false,
    String sortBy = '',
    String page = '',
    String limit = '',
  }) async {
    final queryParams = {
      'search': search,
      'status': status,
      'planId': plan,
      'trainerId': trainer,
      'checkedInToday': checkedInToday.toString(),
      'overdueOnly': overdueOnly.toString(),
      'sortBy': sortBy,
      'page': page,
      'limit': limit,
    }..removeWhere((key, value) => _removeEmpty(value));
    String url = EndPoints.members;
    if (queryParams.isNotEmpty) {
      url += '?${queryParams.filterQueryParams}';
    }
    DioResponse response = await _dio.dioGetCall(url);
    if (response.hasError) return response.handleError();
    return MemberPaginationModel.fromJson(response.response!.data);
  }

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

  @override
  Future<MemberListModel> createMember({
    required String name,
    required String phone,
    required String email,
    required String plan,
    required String trainer,
    required String dob,
    required String startDate,
  }) async {
    final formData = {
      "name": name,
      "phone": phone,
      "email": email,
      "dateOfBirth": dob,
      "password": "",
      "planId": plan,
      "trainerId": trainer,
      "startDate": startDate
    };
    DioResponse response = await _dio.dioPostCall(EndPoints.members, formData);
    if (response.hasError) return response.handleError();
    return MemberListModel.fromJson(response.response!.data['member'] ?? {});
  }

  @override
  Future<List<MembershipPlanMiniModel>> getPlans(bool includeInactive) async {
    DioResponse response = await _dio.dioGetCall("${EndPoints.membershipPlans}?includeInactive=$includeInactive");
    if (response.hasError) return response.handleError();
    return (response.response!.data['plans'] as List)
        .map((e) => MembershipPlanMiniModel.fromJson(e))
        .toList();
  }

  @override
  Future<List<TrainerMiniModel>> getTrainers() async {
    DioResponse response = await _dio.dioGetCall(EndPoints.trainers);
    if (response.hasError) return response.handleError();
    return (response.response!.data['trainers'] as List)
        .map((e) => TrainerMiniModel.fromJson(e))
        .toList();
  }

  @override
  Future<MembershipPlanMiniModel> createMembershipPlan(MembershipPlanMiniModel model) async {
    DioResponse response = await _dio.dioPostCall(EndPoints.membershipPlans, model.toJson());
    if (response.hasError) return response.handleError();
    return MembershipPlanMiniModel.fromJson(response.response!.data['plan'] ?? {});
  }

  @override
  Future<bool> deleteMembershipPlan(String id) async {
    DioResponse response = await _dio.dioDeleteCall(EndPoints.updateOrDeleteMembershipPlan(id));
    if (response.hasError) return response.handleError();
    return true;
  }

  @override
  Future<MembershipPlanMiniModel> updateMembershipPlan(MembershipPlanMiniModel model) async {
    DioResponse response = await _dio.dioPatchCall(EndPoints.updateOrDeleteMembershipPlan(model.id), model.toJson());
    if (response.hasError) return response.handleError();
    return MembershipPlanMiniModel.fromJson(response.response!.data['plan'] ?? {});
  }
}
