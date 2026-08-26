import 'package:club_fitness/config/network/api.dart';

import '../models/home_models.dart';

abstract interface class HomeNetworkDataSource {
  Future<HomeModel> getHomeData(String role);
}

class HomeNetworkDataSourceImpl implements HomeNetworkDataSource {
  final DioConfig _dio;

  const HomeNetworkDataSourceImpl(this._dio);
  @override
  Future<HomeModel> getHomeData(String role) async {
    DioResponse response = await _dio.dioGetCall(EndPoints.home);
    if (response.hasError) return response.handleError();
    final data = response.response!.data;
    HomeModel home;
    switch (role) {
      case 'member':
        home = HomeModel(memberHome: MemberHomeModel.fromJson(data));
        break;
      case 'trainer':
        home = HomeModel(trainerHome: TrainerHomeModel.fromJson(data));
        break;
      case 'admin':
        home = HomeModel(adminHome: AdminHomeModel.fromJson(data));
        break;
      default:
        home = HomeModel(memberHome: MemberHomeModel.fromJson(data));
    }
    return home;
  }
}
