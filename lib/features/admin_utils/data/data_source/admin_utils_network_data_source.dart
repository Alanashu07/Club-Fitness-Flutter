import 'dart:io';

import 'package:club_fitness/config/network/api.dart';
import 'package:club_fitness/core/utils/utils.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';

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

  Future<FeeSummaryModel> getFeeSummary({String? memberId});
  Future<ReportDetailsModel> getSalesReport(
    String range, {
    String? startDate,
    String? endDate,
  });

  Future<FeeDetailModel> getFeeById(String id);

  Future<FeesModel> createFee({
    required String memberId,
    required String dueDate,
    String? planId,
    double? amount,
    String? status,
    double? paidAmount,
    String? paymentMethod,
    String? notes,
  });

  Future<FeesModel> updateFee(
    String id, {
    double? amount,
    String? dueDate,
    String? planId,
    String? notes,
  });

  Future<FeesModel> approveFees(String id);
  Future<FeesModel> rejectFees(String id, {String? reason});

  Future<FeesModel> markFeePaid(
    String id, {
    required double amountReceived,
    required String method,
    String? notes,
  });

  Future<FeesModel> waiveFee(String id, {String? reason});

  /// Pass either [receiptFilePath] (multipart upload) or [receiptUrl].
  Future<FeesModel> attachReceipt(
    String id, {
    String? receiptFilePath,
    String? receiptUrl,
  });

  Future<String> deleteFee(String id);

  /// Returns the PDF bytes of the fee report.
  Future<List<int>> exportFeesPdf({
    String? search,
    String? status,
    String? memberId,
    String? planId,
    String? sortBy,
  });

  Future<String> exportSalesReportPdf(
    String range, {
    String? startDate,
    String? endDate,
    num? txLimit,
  });

  Future<String> exportSalesReportExcel(
    String range, {
    String? startDate,
    String? endDate,
    num? txLimit,
  });
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
  Future<FeeSummaryModel> getFeeSummary({String? memberId}) async {
    final Map<String, dynamic> params = {"memberId": memberId}.clean();
    final String url = params.isEmpty
        ? EndPoints.feeSummary
        : "${EndPoints.feeSummary}?${params.filterQueryParams}";
    DioResponse response = await _dio.dioGetCall(url);
    if (response.hasError) return response.handleError();
    return FeeSummaryModel.fromJson(response.response!.data);
  }

  @override
  Future<ReportDetailsModel> getSalesReport(
    String range, {
    String? startDate,
    String? endDate,
  }) async {
    DioResponse response = await _dio.dioGetCallParams(EndPoints.salesReport, {
      if (startDate == null) 'range': range,
      if (startDate != null) 'startDate': startDate,
      if (endDate != null) 'endDate': endDate,
    });
    if (response.hasError) return response.handleError();
    return ReportDetailsModel.fromJson(response.response!.data);
  }

  @override
  Future<FeeDetailModel> getFeeById(String id) async {
    DioResponse response = await _dio.dioGetCall(EndPoints.feeDetails(id));
    if (response.hasError) return response.handleError();
    return FeeDetailModel.fromJson(response.response!.data ?? {});
  }

  @override
  Future<FeesModel> createFee({
    required String memberId,
    required String dueDate,
    String? planId,
    double? amount,
    String? status,
    double? paidAmount,
    String? paymentMethod,
    String? notes,
  }) async {
    final Map<String, dynamic> body = {
      "memberId": memberId,
      "dueDate": dueDate,
      "planId": planId,
      "amount": amount,
      "status": status,
      "paidAmount": paidAmount,
      "paymentMethod": paymentMethod,
      "notes": notes,
    }.clean();
    DioResponse response = await _dio.dioPostCall(EndPoints.fees, body);
    if (response.hasError) return response.handleError();
    return FeesModel.fromJson(response.response!.data['fee'] ?? {});
  }

  @override
  Future<FeesModel> updateFee(
    String id, {
    double? amount,
    String? dueDate,
    String? planId,
    String? notes,
  }) async {
    final Map<String, dynamic> body = {
      "amount": amount,
      "dueDate": dueDate,
      "planId": planId,
      "notes": notes,
    }.clean();
    DioResponse response = await _dio.dioPatchCall(
      "${EndPoints.fees}/$id",
      body,
    );
    if (response.hasError) return response.handleError();
    return FeesModel.fromJson(response.response!.data['fee'] ?? {});
  }

  @override
  Future<FeesModel> approveFees(String id) async {
    DioResponse response = await _dio.dioPatchCall(
      EndPoints.feeActions(id, FeeActions.approve),
      {},
    );
    if (response.hasError) return response.handleError();
    return FeesModel.fromJson(response.response!.data['fee'] ?? {});
  }

  @override
  Future<FeesModel> rejectFees(String id, {String? reason}) async {
    DioResponse response = await _dio.dioPatchCall(
      EndPoints.feeActions(id, FeeActions.reject),
      {'reason': reason},
    );
    if (response.hasError) return response.handleError();
    return FeesModel.fromJson(response.response!.data['fee'] ?? {});
  }

  @override
  Future<FeesModel> markFeePaid(
    String id, {
    required double amountReceived,
    required String method,
    String? notes,
  }) async {
    final Map<String, dynamic> body = {
      "amountReceived": amountReceived,
      "method": method,
      "notes": notes,
    }.clean();
    DioResponse response = await _dio.dioPatchCall(
      EndPoints.feeActions(id, FeeActions.markPaid),
      body,
    );
    if (response.hasError) return response.handleError();
    return FeesModel.fromJson(response.response!.data['fee'] ?? {});
  }

  @override
  Future<FeesModel> waiveFee(String id, {String? reason}) async {
    DioResponse response = await _dio.dioPatchCall(
      EndPoints.feeActions(id, FeeActions.waive),
      {'reason': reason}.clean(),
    );
    if (response.hasError) return response.handleError();
    return FeesModel.fromJson(response.response!.data['fee'] ?? {});
  }

  @override
  Future<FeesModel> attachReceipt(
    String id, {
    String? receiptFilePath,
    String? receiptUrl,
  }) async {
    final dynamic body = receiptFilePath != null
        ? FormData.fromMap({
            'receipt': await MultipartFile.fromFile(receiptFilePath),
          })
        : {'receiptUrl': receiptUrl};

    DioResponse response = await _dio.dioPostCall(
      EndPoints.feeActions(id, FeeActions.receipt),
      body,
    );
    if (response.hasError) return response.handleError();
    return FeesModel.fromJson(response.response!.data['fee'] ?? {});
  }

  @override
  Future<String> deleteFee(String id) async {
    DioResponse response = await _dio.dioDeleteCall("${EndPoints.fees}/$id");
    if (response.hasError) return response.handleError();
    return response.response!.data['message'] ?? 'Fee record deleted';
  }

  @override
  Future<List<int>> exportFeesPdf({
    String? search,
    String? status,
    String? memberId,
    String? planId,
    String? sortBy,
  }) async {
    final Map<String, dynamic> params = {
      "search": search,
      "status": status,
      "memberId": memberId,
      "planId": planId,
      "sortBy": sortBy,
    }.clean();
    final String url = params.isEmpty
        ? EndPoints.exportFeesPdf
        : "${EndPoints.exportFeesPdf}?${params.filterQueryParams}";
    DioResponse response = await _dio.dioGetMedia(url);
    if (response.hasError) return response.handleError();
    final List<int> bytes = List<int>.from(response.response!.data);
    //Save bytes to application document directory (Safe ios path)
    await File(
      '${Directory.systemTemp.path}/fees_${DateTime.now().millisecondsSinceEpoch}.pdf',
    ).writeAsBytes(bytes);
    return bytes;
  }

  @override
  Future<String> exportSalesReportExcel(
    String range, {
    String? startDate,
    String? endDate,
    num? txLimit,
  }) async {
    String url = EndPoints.exportSalesReportExcel;
    Map<String, dynamic> filters = {
      'range': range,
      'startDate': startDate,
      'endDate': endDate,
      'txLimit': txLimit,
    }.clean();
    if (filters.isNotEmpty) {
      url += '?${filters.filterQueryParams}';
    }
    DioResponse response = await _dio.dioGetMedia(url);
    if (response.hasError) return response.handleError();
    final List<int> bytes = List<int>.from(response.response!.data);
    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/sales-report-$stamp.xlsx');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }

  @override
  Future<String> exportSalesReportPdf(
    String range, {
    String? startDate,
    String? endDate,
    num? txLimit,
  }) async {
    String url = EndPoints.exportSalesReportPdf;
    Map<String, dynamic> filters = {
      'range': range,
      'startDate': startDate,
      'endDate': endDate,
      'txLimit': txLimit,
    }.clean();
    if (filters.isNotEmpty) {
      url += '?${filters.filterQueryParams}';
    }
    DioResponse response = await _dio.dioGetMedia(url);
    if (response.hasError) return response.handleError();
    final List<int> bytes = List<int>.from(response.response!.data);
    final dir = await getApplicationDocumentsDirectory();
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${dir.path}/sales-report-$stamp.pdf');
    await file.writeAsBytes(bytes, flush: true);
    return file.path;
  }
}
