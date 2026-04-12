import 'dart:convert';
import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'session_service.dart';
import '../exceptions/api_exception.dart';

class ApiService {
  static final String baseUrl = dotenv.env['BASE_URL']!;

  // ======================
  // GET
  // ======================
  static Future<dynamic> get(String url) async {
    try {
      final token = await SessionService.getToken();

      final response = await http
          .get(
            Uri.parse("$baseUrl$url"),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException("Tidak dapat terhubung ke server");
    } on TimeoutException {
      throw ApiException("Server terlalu lama merespon");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Terjadi kesalahan");
    }
  }

  // ======================
  // POST
  // ======================
  static Future<dynamic> post(String url, Map data) async {
    try {
      final token = await SessionService.getToken();

      final response = await http
          .post(
            Uri.parse("$baseUrl$url"),
            headers: _headers(token),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException("Tidak dapat terhubung ke server");
    } on TimeoutException {
      throw ApiException("Server terlalu lama merespon");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Terjadi kesalahan");
    }
  }

  // ======================
  // PUT
  // ======================
  static Future<dynamic> put(String url, Map data) async {
    try {
      final token = await SessionService.getToken();

      final response = await http
          .put(
            Uri.parse("$baseUrl$url"),
            headers: _headers(token),
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException("Tidak dapat terhubung ke server");
    } on TimeoutException {
      throw ApiException("Server terlalu lama merespon");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Terjadi kesalahan");
    }
  }

  // ======================
  // DELETE
  // ======================
  static Future<dynamic> delete(String url) async {
    try {
      final token = await SessionService.getToken();

      final response = await http
          .delete(
            Uri.parse("$baseUrl$url"),
            headers: _headers(token),
          )
          .timeout(const Duration(seconds: 15));

      return _handleResponse(response);
    } on SocketException {
      throw ApiException("Tidak dapat terhubung ke server");
    } on TimeoutException {
      throw ApiException("Server terlalu lama merespon");
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException("Terjadi kesalahan");
    }
  }

  // ======================
  // HEADERS
  // ======================
  static Map<String, String> _headers(String? token) {
    return {
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  // ======================
  // RESPONSE HANDLER
  // ======================
  static dynamic _handleResponse(http.Response response) {
    dynamic data;

    try {
      data = jsonDecode(response.body);
    } catch (e) {
      throw ApiException("Response server tidak valid");
    }

    // TOKEN EXPIRED
    if (response.statusCode == 401) {
      SessionService.logout();
      throw ApiException(
        "Session habis, silakan login kembali",
        statusCode: 401,
      );
    }

    // CLIENT / SERVER ERROR
    if (response.statusCode >= 400) {
      throw ApiException(
        data["message"] ?? "Request error",
        statusCode: response.statusCode,
      );
    }

    return data;
  }
}