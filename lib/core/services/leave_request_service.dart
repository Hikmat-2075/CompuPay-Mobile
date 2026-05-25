import 'dart:convert';
import 'dart:io';

import 'package:compupay_mobile/core/config/api_config.dart';
import 'package:compupay_mobile/core/exceptions/api_exception.dart';
import 'package:compupay_mobile/core/services/api_service.dart';
import 'package:compupay_mobile/core/services/session_service.dart';
import 'package:compupay_mobile/models/leave_request_models.dart';
import 'package:http/http.dart' as http;

class LeaveRequestService {
  static const _fallbackSuffixes = [
    'leave-request',
    'leave-requests',
  ];

  static Future<List<LeaveRequestItem>> list({
    int page = 1,
    int limit = 10,
  }) async {
    final query = '?page=$page&limit=$limit';

    for (final endpoint in _candidateEndpoints()) {
      try {
        final response = await ApiService.get('$endpoint$query');
        return parseLeaveRequestList(response);
      } on ApiException catch (e) {
        if (e.statusCode != 404) {
          rethrow;
        }
      }
    }

    return const [];
  }

  static Future<LeaveRequestItem> create({
    required LeaveRequestCreatePayload payload,
    File? attachment,
  }) async {
    ApiException? lastError;

    for (final endpoint in _candidateEndpoints()) {
      try {
        final response = await _createWithMultipart(
          endpoint: endpoint,
          payload: payload,
          attachment: attachment,
        );

        return parseLeaveRequestDetail(response);
      } on ApiException catch (e) {
        lastError = e;
        if (e.statusCode != 404) {
          rethrow;
        }
      }
    }

    throw lastError ?? ApiException('Endpoint leave request tidak ditemukan');
  }

  static Future<dynamic> _createWithMultipart({
    required String endpoint,
    required LeaveRequestCreatePayload payload,
    File? attachment,
  }) async {
    final token = await SessionService.getToken();

    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${ApiService.baseUrl}$endpoint'),
    );

    if (token != null) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    request.fields.addAll(payload.toFields());

    if (attachment != null) {
      request.files.add(
        await http.MultipartFile.fromPath(
          'attachment',
          attachment.path,
        ),
      );
    }

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    dynamic body;
    try {
      body = jsonDecode(response.body);
    } catch (_) {
      throw ApiException('Response server tidak valid');
    }

    if (response.statusCode >= 400) {
      throw ApiException(
        (body is Map<String, dynamic>
                    ? body['message']?.toString()
                    : null) ??
            'Request error',
        statusCode: response.statusCode,
      );
    }

    return body;
  }

  static List<String> _candidateEndpoints() {
    final candidates = <String>{};

    void addPath(String value) {
      final normalized = value.trim();
      if (normalized.isEmpty) {
        return;
      }

      candidates.add(normalized.startsWith('/') ? normalized : '/$normalized');
    }

    addPath(ApiConfig.leaveRequest);

    for (final suffix in _fallbackSuffixes) {
      addPath('${ApiConfig.apiVersion}/$suffix');
    }

    return candidates.toList(growable: false);
  }
}
