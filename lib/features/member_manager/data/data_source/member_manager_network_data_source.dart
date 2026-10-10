import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:dio/dio.dart';

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
    required String userRole,
    required String? profileImagePath,
    required String? offerId,
    required String? offerCode,
  });

  Future<MemberListModel> updateMember({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String plan,
    required String trainer,
    required String dob,
    required String startDate,
    required String? profileImagePath,
    required bool removeProfileImage,
  });

  Future<List<TrainerMiniModel>> getTrainers();
  Future<List<MembershipPlanMiniModel>> getPlans(bool includeInactive);
  Future<MembershipPlanMiniModel> createMembershipPlan(
    MembershipPlanMiniModel model,
  );
  Future<MembershipPlanMiniModel> updateMembershipPlan(
    MembershipPlanMiniModel model,
  );
  Future<bool> deleteMembershipPlan(String id);
  Future<MemberDetailModel> getMemberDetails(String id);
  Future<String> reactivateMember(String id);
  Future<String> deleteMember({required String id, bool force = false});
  Future<String> suspendMember(String id);
  Future<RenewMemberModel> renewMembership({
    required String id,
    required String planId,
    required num paidAmount,
    required String paymentMethod,
    required String notes,
    String? startOverride,
    String? receiptPath,
    required bool waiveRemaining,
    required String? offerId,
    required String? offerCode,
  });

  Future<String> revertLastRenewal(String id);
  Future<String> sendReminder(String id);
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
    required String userRole,
    required String? profileImagePath,
    required String? offerId,
    required String? offerCode,
  }) async {
    String password;
    if (dob.isEmpty) {
      password = '';
    } else {
      DateTime date = dob.toDateTime;
      password =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year.toString().padLeft(4, '0')}';
    }
    final formData = FormData.fromMap({
      "name": name,
      "phone": phone,
      "email": email,
      "dateOfBirth": dob,
      "password": password,
      "planId": plan,
      "trainerId": trainer,
      "startDate": startDate,
      "role": userRole,
      "offerId": offerId,
      "offerCode": offerCode,
      if (profileImagePath != null)
        "profileImage": await MultipartFile.fromFile(profileImagePath),
    });
    DioResponse response = await _dio.dioPostCall(EndPoints.members, formData);
    if (response.hasError) return response.handleError();
    return MemberListModel.fromJson(response.response!.data['member'] ?? {});
  }

  @override
  Future<List<MembershipPlanMiniModel>> getPlans(bool includeInactive) async {
    DioResponse response = await _dio.dioGetCall(
      "${EndPoints.membershipPlans}?includeInactive=$includeInactive",
    );
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
  Future<MembershipPlanMiniModel> createMembershipPlan(
    MembershipPlanMiniModel model,
  ) async {
    DioResponse response = await _dio.dioPostCall(
      EndPoints.membershipPlans,
      model.toJson(),
    );
    if (response.hasError) return response.handleError();
    return MembershipPlanMiniModel.fromJson(
      response.response!.data['plan'] ?? {},
    );
  }

  @override
  Future<bool> deleteMembershipPlan(String id) async {
    DioResponse response = await _dio.dioDeleteCall(
      EndPoints.updateOrDeleteMembershipPlan(id),
    );
    if (response.hasError) return response.handleError();
    return true;
  }

  @override
  Future<MembershipPlanMiniModel> updateMembershipPlan(
    MembershipPlanMiniModel model,
  ) async {
    DioResponse response = await _dio.dioPatchCall(
      EndPoints.updateOrDeleteMembershipPlan(model.id),
      model.toJson(),
    );
    if (response.hasError) return response.handleError();
    return MembershipPlanMiniModel.fromJson(
      response.response!.data['plan'] ?? {},
    );
  }

  @override
  Future<MemberDetailModel> getMemberDetails(String id) async {
    DioResponse response = await _dio.dioGetCall(EndPoints.memberDetails(id));
    if (response.hasError) return response.handleError();
    return MemberDetailModel.fromJson(response.response!.data);
  }

  @override
  Future<MemberListModel> updateMember({
    required String id,
    required String name,
    required String phone,
    required String email,
    required String plan,
    required String trainer,
    required String dob,
    required String startDate,
    required String? profileImagePath,
    required bool removeProfileImage,
  }) async {
    final formData = FormData.fromMap({
      "name": name,
      "phone": phone,
      "email": email,
      "dateOfBirth": dob,
      "planId": plan,
      "trainerId": trainer,
      "startDate": startDate,
      if (profileImagePath != null)
        "profileImage": await MultipartFile.fromFile(profileImagePath),
      "removeProfileImage": removeProfileImage,
    });
    DioResponse response = await _dio.dioPatchCall(
      EndPoints.memberDetails(id),
      formData,
    );

    if (response.hasError) return response.handleError();
    return MemberListModel.fromJson(response.response!.data['member'] ?? {});
  }

  @override
  Future<String> reactivateMember(String id) async {
    DioResponse response = await _dio.dioPatchCall(
      EndPoints.reactivateMember(id),
      {},
    );
    if (response.hasError) return response.handleError();
    return response.response!.data['message'].toString();
  }

  @override
  Future<String> deleteMember({required String id, bool force = false}) async {
    DioResponse response = await _dio.dioDeleteCall(
      EndPoints.memberDetails(id),
      {},
      {'force': force},
    );
    if (response.hasError) return response.handleError();
    return response.response!.data['message'].toString();
  }

  @override
  Future<RenewMemberModel> renewMembership({
    required String id,
    required String planId,
    required num paidAmount,
    required String paymentMethod,
    required String notes,
    String? startOverride,
    String? receiptPath,
    required bool waiveRemaining,
    required String? offerId,
    required String? offerCode,
  }) async {
    final form = FormData.fromMap({
      'planId': planId,
      if (startOverride != null) 'startDate': startOverride,
      'paidAmount': paidAmount,
      'paymentMethod': paymentMethod,
      'notes': notes,
      if (receiptPath != null)
        'receipt': await MultipartFile.fromFile(receiptPath),
      'waiveRemaining': waiveRemaining,
      if (offerId != null) 'offerId': offerId,
      if (offerCode != null) 'offerCode': offerCode,
    });
    DioResponse response = await _dio.dioPostCall(
      EndPoints.renewMembership(id),
      form,
    );
    if (response.hasError) return response.handleError();
    return RenewMemberModel.fromJson(response.response!.data);
  }

  @override
  Future<String> suspendMember(String id) async {
    DioResponse response = await _dio.dioPatchCall(EndPoints.suspendMember(id));
    if (response.hasError) return response.handleError();
    return response.response!.data['message'].toString();
  }

  @override
  Future<String> revertLastRenewal(String id) async {
    DioResponse response = await _dio.dioDeleteCall(
      EndPoints.revertLastRenewal(id),
    );
    if (response.hasError) return response.handleError();
    return response.response!.data['message'].toString();
  }

  @override
  Future<String> sendReminder(String id) async {
    DioResponse response = await _dio.dioPostCall(
      EndPoints.sendReminder(id),
      {},
    );
    if (response.hasError) return response.handleError();
    return response.response!.data['message'].toString();
  }
}
