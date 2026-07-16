import '../entities/home_summary.dart';
import '../repositories/home_repository.dart';

class GetHomeSummary {
  final HomeRepository repository;
  GetHomeSummary(this.repository);

  Future<HomeSummary> call() => repository.getSummary();
}
