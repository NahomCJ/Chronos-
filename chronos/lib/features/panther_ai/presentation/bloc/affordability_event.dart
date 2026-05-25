abstract class AffordabilityEvent {
  const AffordabilityEvent();
}

class AffordabilityCheckRequested extends AffordabilityEvent {
  final double amount;
  final String merchant;
  const AffordabilityCheckRequested({required this.amount, required this.merchant});
}
