class AffordabilityResult {
  final String verdict;
  final String summary;
  final double? safeAmount;

  const AffordabilityResult({
    required this.verdict,
    required this.summary,
    this.safeAmount,
  });
}
