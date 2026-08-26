import '../../../core/network/api_client.dart';

class LifeXService {
  final ApiClient _api;
  LifeXService(this._api);

  // ── Health ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> healthDashboard() =>
      _api.get('/api/lifex/health/dashboard');
  Future<List<dynamic>> healthMetrics() =>
      _api.getList('/api/lifex/health/metrics');
  Future<List<dynamic>> fitnessHistory() =>
      _api.getList('/api/lifex/health/fitness');
  Future<List<dynamic>> habits() =>
      _api.getList('/api/lifex/health/habits');
  Future<Map<String, dynamic>> logFitness(Map<String, dynamic> body) =>
      _api.post('/api/lifex/health/fitness', body);
  Future<Map<String, dynamic>> logHabit(Map<String, dynamic> body) =>
      _api.post('/api/lifex/health/habit', body);
  Future<Map<String, dynamic>> getHsa() => _api.get('/api/lifex/health/hsa');
  Future<Map<String, dynamic>> depositHsa(double amount) =>
      _api.post('/api/lifex/health/hsa/deposit', {'amount': amount});
  Future<Map<String, dynamic>> withdrawHsa(double amount) =>
      _api.post('/api/lifex/health/hsa/withdraw', {'amount': amount});
  Future<List<dynamic>> gyms({String? city}) =>
      _api.getList('/api/lifex/health/gyms${city != null ? '?city=$city' : ''}');
  Future<Map<String, dynamic>> enrollInsurance(Map<String, dynamic> body) =>
      _api.post('/api/lifex/health/insurance/enroll', body);
  Future<List<dynamic>> myInsurance() =>
      _api.getList('/api/lifex/health/insurance/mine');
  Future<Map<String, dynamic>> connectNutritionPartner(Map<String, dynamic> body) =>
      _api.post('/api/lifex/health/nutrition-partners/connect', body);
  Future<List<dynamic>> myNutritionConnections() =>
      _api.getList('/api/lifex/health/nutrition-partners/mine');
  Future<List<dynamic>> wearableProviders() =>
      _api.getList('/api/lifex/health/wearables/providers');
  Future<Map<String, dynamic>> connectWearable(String provider) =>
      _api.post('/api/lifex/health/wearables/connect', {'provider': provider});
  Future<List<dynamic>> myWearableConnections() =>
      _api.getList('/api/lifex/health/wearables/mine');
  Future<Map<String, dynamic>> syncWearableMetrics(Map<String, dynamic> body) =>
      _api.post('/api/lifex/health/wearables/sync', body);
  Future<List<dynamic>> healthInsights() =>
      _api.getList('/api/lifex/health/insights');

  // ── Spiritual ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> spiritualDashboard() =>
      _api.get('/api/lifex/spiritual/dashboard');
  Future<Map<String, dynamic>> spiritualStreak() =>
      _api.get('/api/lifex/spiritual/streak');
  Future<List<dynamic>> gratitude() =>
      _api.getList('/api/lifex/spiritual/gratitude');
  Future<List<dynamic>> spiritualGoals() =>
      _api.getList('/api/lifex/spiritual/goals');
  Future<Map<String, dynamic>> addGratitude(Map<String, dynamic> body) =>
      _api.post('/api/lifex/spiritual/gratitude', body);
  Future<List<dynamic>> donationHistory() =>
      _api.getList('/api/lifex/spiritual/donations');
  Future<Map<String, dynamic>> donate(Map<String, dynamic> body) =>
      _api.post('/api/lifex/spiritual/donations', body);
  Future<List<dynamic>> campaignContributions() =>
      _api.getList('/api/lifex/spiritual/campaigns/contributions');
  Future<Map<String, dynamic>> contributeToCampaign(Map<String, dynamic> body) =>
      _api.post('/api/lifex/spiritual/campaigns/contribute', body);
  Future<List<dynamic>> tripBookings() =>
      _api.getList('/api/lifex/spiritual/trips/bookings');
  Future<Map<String, dynamic>> bookTrip(Map<String, dynamic> body) =>
      _api.post('/api/lifex/spiritual/trips/book', body);
  Future<List<dynamic>> spiritualOrders() =>
      _api.getList('/api/lifex/spiritual/shop/orders');
  Future<Map<String, dynamic>> checkoutSpiritualShop(Map<String, dynamic> body) =>
      _api.post('/api/lifex/spiritual/shop/checkout', body);
  Future<Map<String, dynamic>> getFaith() =>
      _api.get('/api/lifex/spiritual/faith');
  Future<Map<String, dynamic>> setFaith(String faith) =>
      _api.patch('/api/lifex/spiritual/faith', {'faith': faith});

  // ── Education ────────────────────────────────────────────────────────────
  Future<List<dynamic>> courses() =>
      _api.getList('/api/lifex/education/courses');
  Future<List<dynamic>> scholarships() =>
      _api.getList('/api/lifex/education/scholarships');
  Future<List<dynamic>> tutors() =>
      _api.getList('/api/lifex/education/tutors');

  // ── Finance ──────────────────────────────────────────────────────────────
  Future<List<dynamic>> budgets() =>
      _api.getList('/api/lifex/finance/budgets');
  Future<List<dynamic>> financialPlans() =>
      _api.getList('/api/lifex/finance/plans');

  // ── Vision ───────────────────────────────────────────────────────────────
  Future<List<dynamic>> visionBoards() =>
      _api.getList('/api/lifex/vision/boards');
  Future<List<dynamic>> visionGoals() =>
      _api.getList('/api/lifex/vision/goals');

  // ── Activity ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> activityDashboard() =>
      _api.get('/api/lifex/activity/dashboard');
  Future<List<dynamic>> activityLogs() =>
      _api.getList('/api/lifex/activity/logs');

  // ── Family ───────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> familyGroup() =>
      _api.get('/api/lifex/family/group');
  Future<List<dynamic>> familyGoals() =>
      _api.getList('/api/lifex/family/goals');

  // ── Social ───────────────────────────────────────────────────────────────
  Future<List<dynamic>> communityFeed() =>
      _api.getList('/api/lifex/social/feed');
  Future<List<dynamic>> myPosts() =>
      _api.getList('/api/lifex/social/posts');

  // ── Feed ─────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> unifiedFeed() =>
      _api.get('/api/lifex/feed');

  // ── AI Coach ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> aiInsights() =>
      _api.get('/api/lifex/ai/insights');
  Future<Map<String, dynamic>> weeklyPlan() =>
      _api.get('/api/lifex/ai/weekly-plan');
}
