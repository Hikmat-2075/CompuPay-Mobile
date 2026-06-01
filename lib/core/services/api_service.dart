import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:compupay_mobile/core/navigation/app_navigator.dart';
import 'package:http_parser/http_parser.dart';
import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static String get baseUrl => ApiConfig.baseUrl;

  static Future<dynamic> get(String endpoint) async {
    try {
      _validateBaseUrl();

      final token = await SessionService.getToken();
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .get(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Server terlalu lama merespon');
    } on FormatException {
      throw ApiException('Format URL tidak valid');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan saat mengambil data');
    }
  }

  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      _validateBaseUrl();

      final token = await SessionService.getToken();
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .post(uri, headers: _headers(token), body: jsonEncode(data))
          .timeout(const Duration(seconds: 20));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Server terlalu lama merespon');
    } on FormatException {
      throw ApiException('Format URL tidak valid');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan saat mengirim data');
    }
  }

  static Future<dynamic> put(String endpoint, Map<String, dynamic> data) async {
    try {
      _validateBaseUrl();

      final token = await SessionService.getToken();
      final uri = Uri.parse('$baseUrl$endpoint');
      print('====================');
      print('PUT URL');
      print(uri);

      print('PUT BODY');
      print(jsonEncode(data));
      print('====================');
      final response = await http
          .put(uri, headers: _headers(token), body: jsonEncode(data))
          .timeout(const Duration(seconds: 20));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Server terlalu lama merespon');
    } on FormatException {
      throw ApiException('Format URL tidak valid');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan saat mengubah data');
    }
  }

  static Future<dynamic> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      _validateBaseUrl();

      final token = await SessionService.getToken();
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .patch(uri, headers: _headers(token), body: jsonEncode(data))
          .timeout(const Duration(seconds: 20));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Server terlalu lama merespon');
    } on FormatException {
      throw ApiException('Format URL tidak valid');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan saat mengubah data');
    }
  }

  static Future<dynamic> delete(String endpoint) async {
    try {
      _validateBaseUrl();

      final token = await SessionService.getToken();
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .delete(uri, headers: _headers(token))
          .timeout(const Duration(seconds: 20));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Server terlalu lama merespon');
    } on FormatException {
      throw ApiException('Format URL tidak valid');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan saat menghapus data');
    }
  }

  static Future<dynamic> multipartPost({
    required String endpoint,
    required Map<String, String> fields,
    File? file,
    Uint8List? fileBytes,
    String? filename,
    String fileField = 'attachment',
  }) async {
    try {
      _validateBaseUrl();

      final token = await SessionService.getToken();
      final uri = Uri.parse('$baseUrl$endpoint');

      final request = http.MultipartRequest('POST', uri);

      request.headers['Accept'] = 'application/json';

      if (token != null && token.trim().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }

      request.fields.addAll(fields);

      if (fileBytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            fileField,
            fileBytes,
            filename: filename ?? 'attendance_photo.jpg',
            contentType: MediaType('image', 'jpeg'),
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 30),
      );

      final response = await http.Response.fromStream(streamedResponse);

      return _handleResponse(response);
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Server terlalu lama merespon');
    } on FormatException {
      throw ApiException('Format URL tidak valid');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan saat upload data');
    }
  }

  static Map<String, String> _headers(String? token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null && token.trim().isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> _handleResponse(http.Response response) async {
    dynamic body;

    if (response.body.trim().isEmpty) {
      body = null;
    } else {
      try {
        body = jsonDecode(response.body);
      } catch (_) {
        throw ApiException(
          'Response server tidak valid',
          statusCode: response.statusCode,
        );
      }
    }

    if (response.statusCode == 401) {
      await SessionService.logout();
      AppNavigator.goToLogin();

      throw ApiException(
        'Session habis, silakan login kembali',
        statusCode: 401,
      );
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        _extractErrorMessage(body),
        statusCode: response.statusCode,
      );
    }

    return body;
  }

  static String _extractErrorMessage(dynamic body) {
    if (body is Map) {
      final message = body['message'];
      final errors = body['errors'];

      if (message != null && message.toString().trim().isNotEmpty) {
        return message.toString();
      }

      if (errors != null && errors.toString().trim().isNotEmpty) {
        return errors.toString();
      }
    }

    return 'Request error';
  }

  static void _validateBaseUrl() {
    if (baseUrl.trim().isEmpty) {
      throw ApiException('BASE_URL belum dikonfigurasi');
    }
  }

  static Future<Uint8List> downloadFile(String endpoint) async {
    try {
      _validateBaseUrl();

      final token = await SessionService.getToken();
      final uri = Uri.parse('$baseUrl$endpoint');

      final response = await http
          .get(
            uri,
            headers: {
              'Accept': 'application/pdf',
              if (token != null && token.trim().isNotEmpty)
                'Authorization': 'Bearer $token',
            },
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode == 401) {
        await SessionService.logout();
        throw ApiException(
          'Session habis, silakan login kembali',
          statusCode: 401,
        );
      }

      if (response.statusCode >= 400) {
        throw ApiException(
          'Gagal download PDF',
          statusCode: response.statusCode,
        );
      }

      return response.bodyBytes;
    } on SocketException {
      throw ApiException('Tidak dapat terhubung ke server');
    } on TimeoutException {
      throw ApiException('Server terlalu lama merespon');
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException('Terjadi kesalahan saat download PDF');
    }
  }
}
