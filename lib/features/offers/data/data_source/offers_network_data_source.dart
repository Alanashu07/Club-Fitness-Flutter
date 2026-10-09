import 'package:club_fitness/config/network/api.dart';

import '../../domain/entities/offers_entities.dart';
import '../models/offers_models.dart';

abstract interface class OffersNetworkDataSource {
  Future<List<OfferModel>> getOffers(OfferFilters? f);
  Future<OfferModel> createOffer(OfferModel offer);
  Future<OfferModel> updateOffer(OfferModel offer);
  Future<String> deleteOffer(String id);
}

class OffersNetworkDataSourceImpl implements OffersNetworkDataSource {
  final DioConfig _dio;

  const OffersNetworkDataSourceImpl(this._dio);
  @override
  Future<OfferModel> createOffer(OfferModel offer) async {
    final planIds = offer.plans.map((p) => p.id).toList();
    final formData = {...offer.toJson(), 'planIds': planIds};
    DioResponse response = await _dio.dioPostCall(EndPoints.offers, formData);
    if (response.hasError) return response.handleError();
    return OfferModel.fromJson(response.response!.data['offer'] ?? {});
  }

  @override
  Future<String> deleteOffer(String id) async {
    DioResponse response = await _dio.dioDeleteCall(EndPoints.offerDetails(id));
    if (response.hasError) return response.handleError();
    return response.response!.data['message'].toString();
  }

  @override
  Future<List<OfferModel>> getOffers(OfferFilters? f) async {
    Map<String, dynamic> query = f?.toQuery() ?? {};
    DioResponse response = await _dio.dioGetCallParams(EndPoints.offers, query);
    if (response.hasError) return response.handleError();
    return (response.response!.data['offers'] as List)
        .map((e) => OfferModel.fromJson(e))
        .toList();
  }

  @override
  Future<OfferModel> updateOffer(OfferModel offer) async {
    final planIds = offer.plans.map((p) => p.id).toList();
    final formData = {
      ...offer.toJson(),
      if (planIds.isNotEmpty) 'planIds': planIds,
    };
    DioResponse response = await _dio.dioPatchCall(
      EndPoints.offerDetails(offer.id),
      formData,
    );
    if (response.hasError) return response.handleError();
    return OfferModel.fromJson(response.response!.data['offer'] ?? {});
  }
}
