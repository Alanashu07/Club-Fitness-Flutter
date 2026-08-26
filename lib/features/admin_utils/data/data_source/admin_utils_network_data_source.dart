import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/core/utils/utils.dart';

import '../models/admin_utils_models.dart';

abstract interface class AdminUtilsNetworkDataSource {
  Future<FeeResponseModel> getFees({
    required String search,
    required String status,
    required String? memberId,
    required String? planId,
    required String sortBy,
    required String page,
    required String limit,
  });

  Future<FeeSummaryModel> getFeeSummary();
  Future<ReportDetailsModel> getSalesReport(String range);
}

class AdminUtilsNetworkDataSourceImpl implements AdminUtilsNetworkDataSource {
  final DioConfig _dio;
  const AdminUtilsNetworkDataSourceImpl(this._dio);
  @override
  Future<FeeResponseModel> getFees({
    required String search,
    required String status,
    required String? memberId,
    required String? planId,
    required String sortBy,
    required String page,
    required String limit,
  }) async {
    final Map<String, dynamic> params = {
      "search": search,
      "status": status,
      "memberId": memberId,
      "planId": planId,
      "sortBy": sortBy,
      "page": page,
      "limit": limit,
    }.clean();
    DioResponse response = await _dio.dioGetCall(
      "${EndPoints.fees}?${params.filterQueryParams}",
    );
    if (response.hasError) return response.handleError();
    return FeeResponseModel.fromJson(response.response!.data);
  }

  @override
  Future<FeeSummaryModel> getFeeSummary() async {
    DioResponse response = await _dio.dioGetCall(EndPoints.feeSummary);
    if (response.hasError) return response.handleError();
    return FeeSummaryModel.fromJson(response.response!.data);
  }

  @override
  Future<ReportDetailsModel> getSalesReport(String range) async {
    DioResponse response = await _dio.dioGetCall("${EndPoints.salesReport}?range=$range");
    if (response.hasError) return response.handleError();
    return ReportDetailsModel.fromJson(response.response!.data);
  }
}
