import '../../domain/entities/home_summary.dart';
import '../../domain/repositories/home_repository.dart';
import '../data_source/home_remote_data_source.dart';

class HomeRepositoryImpl implements HomeRepository {
  final HomeRemoteDataSource dataSource;
  HomeRepositoryImpl(this.dataSource);

  @override
  Future<HomeSummary> getSummary() async {
    final model = await dataSource.getSummary();
    return model.toEntity();
  }
}
