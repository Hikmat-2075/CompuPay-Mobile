import 'dart:convert';

class JwtUtils {
  static Map<String, dynamic>? decodePayload(String token) {
    try {
      final parts = token.split('.');

      if (parts.length != 3) {
        return null;
      }

      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));

      final data = jsonDecode(decoded);

      if (data is Map<String, dynamic>) {
        return data;
      }

      if (data is Map) {
        return data.map((key, value) => MapEntry(key.toString(), value));
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  static String? getString(Map<String, dynamic>? payload, List<String> keys) {
    if (payload == null) {
      return null;
    }

    final normalizedKeys = keys.map(_normalizeKey).toSet();

    for (final entry in payload.entries) {
      final key = _normalizeKey(entry.key);

      if (normalizedKeys.contains(key)) {
        final value = entry.value?.toString().trim();

        if (value != null && value.isNotEmpty) {
          return value;
        }
      }
    }

    return null;
  }

  static bool isExpired(String token) {
    final payload = decodePayload(token);
    final exp = payload?['exp'];

    if (exp == null) {
      return false;
    }

    final expValue = int.tryParse(exp.toString());

    if (expValue == null) {
      return false;
    }

    final expiredAt = DateTime.fromMillisecondsSinceEpoch(expValue * 1000);
    return DateTime.now().isAfter(expiredAt);
  }

  static String _normalizeKey(String value) {
    return value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
  }
}
