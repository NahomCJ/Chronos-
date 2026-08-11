import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import '../../features/auth/data/services/token_storage_service.dart';

const _kBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://chronos.us-east-1.elasticbeanstalk.com',
);

class ApiClient {
  final http.Client _client;
  final TokenStorageService _tokenStorage;
  final String baseUrl;

  ApiClient({
    required http.Client client,
    required TokenStorageService tokenStorage,
    String? baseUrl,
  })  : _client = client,
        _tokenStorage = tokenStorage,
        baseUrl = baseUrl ?? _kBaseUrl;

  Map<String, String> get _headers {
    final token = _tokenStorage.accessToken;
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  Future<Map<String, dynamic>> get(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleMapResponse(response);
  }

  Future<List<dynamic>> getList(String path) async {
    final response = await _client.get(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body) as List<dynamic>;
    }
    throw Exception(_extractError(response) ?? 'Request failed');
  }

  Future<Map<String, dynamic>> post(String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleMapResponse(response);
  }

  Future<Map<String, dynamic>> getWithBase(String base, String path) async {
    final response = await _client.get(
      Uri.parse('$base$path'),
      headers: _headers,
    );
    return _handleMapResponse(response);
  }

  Future<Map<String, dynamic>> postWithBase(
      String base, String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$base$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleMapResponse(response);
  }

  Future<Uint8List> postBytesWithBase(
      String base, String path, Map<String, dynamic> body) async {
    final response = await _client.post(
      Uri.parse('$base$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response.bodyBytes;
    }
    throw Exception(
      _extractError(response) ?? 'Request failed (${response.statusCode})',
    );
  }

  Future<Map<String, dynamic>> patch(String path, Map<String, dynamic> body) async {
    final response = await _client.patch(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    return _handleMapResponse(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _client.delete(
      Uri.parse('$baseUrl$path'),
      headers: _headers,
    );
    return _handleMapResponse(response);
  }

  Map<String, dynamic> _handleMapResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      return {'data': decoded};
    }
    throw Exception(
      _extractError(response) ?? 'Request failed (${response.statusCode})',
    );
  }

  String? _extractError(http.Response response) {
    try {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return json['error'] as String? ?? json['message'] as String?;
    } catch (_) {
      return null;
    }
  }
}
