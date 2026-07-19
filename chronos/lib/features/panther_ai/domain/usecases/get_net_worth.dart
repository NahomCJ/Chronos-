import '../entities/net_worth.dart';
import '../repositories/panther_ai_repository.dart';

class GetNetWorthDashboard {
  final PantherAiRepository repository;
  GetNetWorthDashboard(this.repository);
  Future<NetWorthSummary> call() => repository.getNetWorthDashboard();
}

class GetNetWorthProjection {
  final PantherAiRepository repository;
  GetNetWorthProjection(this.repository);
  Future<NetWorthProjection> call({
    int months = 12,
    double monthlyContributionDelta = 0,
    double annualInvestmentReturnPct = 7,
  }) =>
      repository.getNetWorthProjection(
        months: months,
        monthlyContributionDelta: monthlyContributionDelta,
        annualInvestmentReturnPct: annualInvestmentReturnPct,
      );
}
