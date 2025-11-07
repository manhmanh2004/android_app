import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiClient {
  static const String baseUrl = 'http://127.0.0.1:8008/api';

  static String? _token;

  static void setToken(String token) {
    _token = token;
    print('✅ Token đã được lưu: $_token');
  }

  static void clearToken() {
    _token = null;
    print('🚪 Token đã bị xoá.');
  }

  static Map<String, String> _headers() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<dynamic> get(String endpoint) async {
    return _sendRequest('GET', endpoint);
  }

  static Future<dynamic> post(
    String endpoint, [
    Map<String, dynamic>? body,
  ]) async {
    return _sendRequest('POST', endpoint, body);
  }

  static Future<dynamic> put(
    String endpoint, [
    Map<String, dynamic>? body,
  ]) async {
    return _sendRequest('PUT', endpoint, body);
  }

  static Future<dynamic> delete(String endpoint) async {
    return _sendRequest('DELETE', endpoint);
  }

  static Future<dynamic> _sendRequest(
    String method,
    String endpoint, [
    Map<String, dynamic>? body,
  ]) async {
    final cleanEndpoint = endpoint.startsWith('/')
        ? endpoint.substring(1)
        : endpoint;
    final uri = Uri.parse('$baseUrl/$cleanEndpoint');

    http.Response response;

    try {
      print('📤 [$method] $uri');
      print('🔑 Headers: ${_headers()}');
      if (body != null) print('📦 Body: $body');

      switch (method) {
        case 'GET':
          response = await http.get(uri, headers: _headers());
          break;
        case 'POST':
          response = await http.post(
            uri,
            headers: _headers(),
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'PUT':
          response = await http.put(
            uri,
            headers: _headers(),
            body: jsonEncode(body ?? {}),
          );
          break;
        case 'DELETE':
          response = await http.delete(uri, headers: _headers());
          break;
        default:
          throw Exception('HTTP method không hợp lệ: $method');
      }

      print('🔹 Response: ${response.statusCode} ${response.body}');

      if (response.statusCode == 401) {
        throw Exception('❌ Token hết hạn hoặc không hợp lệ');
      }
      if (response.statusCode == 403) {
        throw Exception('🚫 Không có quyền truy cập (403 Forbidden)');
      }

      return _handleResponse(response);
    } catch (e) {
      print('❌ Lỗi request: $e');
      rethrow;
    }
  }

  static dynamic _handleResponse(http.Response res) {
    final status = res.statusCode;
    if (res.body.isEmpty) return null;

    final body = jsonDecode(res.body);

    if (status >= 200 && status < 300) {
      return body;
    } else {
      throw Exception(
        'Lỗi API ($status): ${body['message'] ?? res.reasonPhrase}',
      );
    }
  }
}
