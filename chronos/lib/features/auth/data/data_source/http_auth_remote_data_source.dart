import 'dart:convert';
import 'dart:io';
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

  Map<String, dynamic> _decodeOrThrow(http.Response response, String fallback) {
    try {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } catch (_) {
      throw Exception(fallback);
    }
  }

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
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/auth/login'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel.fromJson(jsonDecode(response.body));
      }
      throw Exception(_extractError(response, 'Invalid credentials'));
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception('Server unreachable. Please try again later.');
    }
  }

  @override
  Future<LoginResponseModel> register(
    String email,
    String password,
    String name,
  ) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/auth/register'),
        headers: _headers,
        body: jsonEncode({'email': email, 'password': password, 'name': name}),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return LoginResponseModel.fromJson(jsonDecode(response.body));
      }
      throw Exception(_extractError(response, 'Registration failed'));
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception('Server unreachable. Please try again later.');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/api/v1/auth/forgot-password'),
        headers: _headers,
        body: jsonEncode({'email': email}),
      );
      if (response.statusCode != 200 && response.statusCode != 201) {
        throw Exception(_extractError(response, 'Failed to send reset code'));
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception('Server unreachable. Please try again later.');
    }
  }

  @override
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
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
        final _ = _decodeOrThrow(response, 'Failed to reset password');
        throw Exception(_extractError(response, 'Failed to reset password'));
      }
    } on SocketException {
      throw Exception('No internet connection. Please check your network.');
    } on HttpException {
      throw Exception('Server unreachable. Please try again later.');
    }
  }
}
