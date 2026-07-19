import '../../../../core/network/api_client.dart';
import '../models/home_model.dart';

class HomeRemoteDataSource {
  final ApiClient _api;
  HomeRemoteDataSource(this._api);

  Future<HomeSummaryModel> getSummary() async {
    final json = await _api.get('/api/home/summary');
    return HomeSummaryModel.fromJson(json);
  }
}
