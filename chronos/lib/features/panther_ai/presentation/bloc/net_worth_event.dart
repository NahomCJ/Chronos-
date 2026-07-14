abstract class NetWorthEvent {
  const NetWorthEvent();
}

class NetWorthLoadRequested extends NetWorthEvent {
  const NetWorthLoadRequested();
}

class NetWorthProjectionRequested extends NetWorthEvent {
  final int months;
  final double monthlyContributionDelta;
  const NetWorthProjectionRequested({
    this.months = 12,
    this.monthlyContributionDelta = 300,
  });
}
