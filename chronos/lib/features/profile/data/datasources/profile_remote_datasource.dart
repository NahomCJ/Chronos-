import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/network/api_client.dart';

class UserProfileModel {
  final String id;
  final String firstName;
  final String? middleName;
  final String lastName;
  final String email;
  final String? phone;
  final String tier;
  final String userLevel;
  final DateTime memberSince;
  final double balance;
  final int transactionCount;

  const UserProfileModel({
    required this.id,
    required this.firstName,
    this.middleName,
    required this.lastName,
    required this.email,
    this.phone,
    required this.tier,
    required this.userLevel,
    required this.memberSince,
    required this.balance,
    required this.transactionCount,
  });

  String get fullName {
    final parts = [firstName, if (middleName != null) middleName, lastName];
    return parts.join(' ');
  }

  String get initials {
    final f = firstName.isNotEmpty ? firstName[0] : '';
    final l = lastName.isNotEmpty ? lastName[0] : '';
    return '$f$l'.toUpperCase();
  }

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    final stats = json['stats'] as Map<String, dynamic>? ?? {};
    return UserProfileModel(
      id: json['id'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      middleName: json['middleName'] as String?,
      lastName: json['lastName'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phone: json['phone'] as String?,
      tier: json['tier'] as String? ?? 'standard',
      userLevel: json['userLevel'] as String? ?? 'BEGINNER',
      memberSince: DateTime.tryParse(json['memberSince'] as String? ?? '') ??
          DateTime.now(),
      balance: (stats['balance'] as num?)?.toDouble() ?? 0.0,
      transactionCount: (stats['transactionCount'] as num?)?.toInt() ?? 0,
    );
  }

  UserProfileModel copyWith({
    String? firstName,
    String? lastName,
    String? phone,
  }) {
    return UserProfileModel(
      id: id,
      firstName: firstName ?? this.firstName,
      middleName: middleName,
      lastName: lastName ?? this.lastName,
      email: email,
      phone: phone ?? this.phone,
      tier: tier,
      userLevel: userLevel,
      memberSince: memberSince,
      balance: balance,
      transactionCount: transactionCount,
    );
  }
}

class ProfileRemoteDataSource {
  final ApiClient _api;
  ProfileRemoteDataSource(this._api);

  /// Try the dedicated profile endpoint first.
  /// Falls back to building profile from JWT payload + home summary
  /// so the Profile page works even before /api/v1/users/me is deployed.
  Future<UserProfileModel> getProfile() async {
    // Primary: dedicated endpoint (available when local backend is running)
    try {
      final json = await _api.get('/api/v1/users/me');
      return UserProfileModel.fromJson(json);
    } catch (_) {}

    // Fallback: decode JWT for email/userId, home summary for balance
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_access_token') ?? '';

    String email = '';
    String userId = '';
    String firstName = '';
    String lastName = '';

    if (token.isNotEmpty) {
      try {
        final parts = token.split('.');
        if (parts.length == 3) {
          final padded = base64Url.normalize(parts[1]);
          final payload = utf8.decode(base64Url.decode(padded));
          final data = jsonDecode(payload) as Map<String, dynamic>;
          userId = data['userId'] as String? ?? '';
          email = data['email'] as String? ?? '';
          firstName = data['firstName'] as String? ?? '';
          lastName = data['lastName'] as String? ?? '';
        }
      } catch (_) {}
    }

    double balance = 0.0;
    int txCount = 0;
    try {
      final home = await _api.get('/api/home/summary');
      balance = (home['totalBalance'] as num?)?.toDouble() ?? 0.0;
      txCount = (home['transactionCount'] as num?)?.toInt() ?? 0;
    } catch (_) {}

    return UserProfileModel(
      id: userId,
      firstName: firstName,
      lastName: lastName,
      email: email,
      tier: 'standard',
      userLevel: 'BEGINNER',
      memberSince: DateTime.now(),
      balance: balance,
      transactionCount: txCount,
    );
  }

  Future<UserProfileModel> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
  }) async {
    final body = <String, dynamic>{};
    if (firstName != null) body['firstName'] = firstName;
    if (lastName != null) body['lastName'] = lastName;
    if (phone != null) body['phone'] = phone;
    // Try dedicated endpoint; fallback returns current cached state
    try {
      final json = await _api.patch('/api/v1/users/me', body);
      return UserProfileModel.fromJson(json);
    } catch (_) {
      return getProfile();
    }
  }
}
