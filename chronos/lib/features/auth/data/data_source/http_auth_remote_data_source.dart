import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_remote_data_source.dart';
import '../models/auth_response_model.dart';

const _kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://chronos.us-east-1.elasticbeanstalk.com',
);

class HttpAuthRemoteDataSource implements AuthRemoteDataSource {
  final http.Client client;
  final String baseUrl;

  HttpAuthRemoteDataSource({required this.client, String? baseUrl})
      : baseUrl = baseUrl ?? _kBaseUrl;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  String _extractError(http.Response response, String fallback) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return (json['error'] ?? json['message'] ?? fallback).toString();
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<LoginResponseModel> login(String email, String password) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/auth/login'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(_extractError(response, 'Invalid credentials'));
  }

  @override
  Future<LoginResponseModel> register(
    String email,
    String password,
    String name,
  ) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/auth/register'),
      headers: _headers,
      body: jsonEncode({'email': email, 'password': password, 'name': name}),
    );
    if (response.statusCode == 200 || response.statusCode == 201) {
      return LoginResponseModel.fromJson(jsonDecode(response.body));
    }
    throw Exception(_extractError(response, 'Registration failed'));
  }

  @override
  Future<void> forgotPassword(String email) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/auth/forgot-password'),
      headers: _headers,
      body: jsonEncode({'email': email}),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractError(response, 'Failed to send reset code'));
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    final response = await client.post(
      Uri.parse('$baseUrl/api/v1/auth/reset-password'),
      headers: _headers,
      body: jsonEncode({
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extractError(response, 'Failed to reset password'));
    }
  }
}
