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

  // ── Spiritual ─────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> spiritualDashboard() =>
      _api.get('/api/lifex/spiritual/dashboard');
  Future<Map<String, dynamic>> spiritualStreak() =>
      _api.get('/api/lifex/spiritual/streak');
  Future<List<dynamic>> meditations() =>
      _api.getList('/api/lifex/spiritual/meditation');
  Future<Map<String, dynamic>> meditationStats() =>
      _api.get('/api/lifex/spiritual/meditation/stats');
  Future<List<dynamic>> gratitude() =>
      _api.getList('/api/lifex/spiritual/gratitude');
  Future<List<dynamic>> spiritualGoals() =>
      _api.getList('/api/lifex/spiritual/goals');
  Future<Map<String, dynamic>> logMeditation(Map<String, dynamic> body) =>
      _api.post('/api/lifex/spiritual/meditation', body);
  Future<Map<String, dynamic>> addGratitude(Map<String, dynamic> body) =>
      _api.post('/api/lifex/spiritual/gratitude', body);

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
