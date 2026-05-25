enum LeaveRequestType { cuti, sakit }

extension LeaveRequestTypeValue on LeaveRequestType {
  String get apiValue {
    switch (this) {
      case LeaveRequestType.cuti:
        return 'CUTI';
      case LeaveRequestType.sakit:
        return 'SAKIT';
    }
  }

  String get label {
    switch (this) {
      case LeaveRequestType.cuti:
        return 'Cuti';
      case LeaveRequestType.sakit:
        return 'Sakit';
    }
  }

  static LeaveRequestType fromValue(String? value) {
    final normalized = (value ?? '').trim().toUpperCase();

    switch (normalized) {
      case 'SAKIT':
        return LeaveRequestType.sakit;
      case 'CUTI':
      default:
        return LeaveRequestType.cuti;
    }
  }
}

class LeaveRequestItem {
  final String id;
  final String userId;
  final LeaveRequestType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final String? attachment;
  final String status;
  final DateTime? createdAt;

  const LeaveRequestItem({
    required this.id,
    required this.userId,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.attachment,
    required this.status,
    required this.createdAt,
  });

  factory LeaveRequestItem.fromJson(Map<String, dynamic> json) {
    final startDate = _parseDate(json['startDate'] ?? json['start_date']);
    final endDate = _parseDate(json['endDate'] ?? json['end_date']);

    return LeaveRequestItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? json['userId'] ?? '').toString(),
      type: LeaveRequestTypeValue.fromValue(json['type']?.toString()),
      startDate: startDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now(),
      reason: (json['reason'] ?? '').toString(),
      attachment: _parseNullableString(json['attachment']),
      status: (json['status'] ?? 'PENDING').toString(),
      createdAt: _parseDate(json['created_at'] ?? json['createdAt']),
    );
  }
}

class LeaveRequestCreatePayload {
  final LeaveRequestType type;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;

  const LeaveRequestCreatePayload({
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.reason,
  });

  Map<String, String> toFields() {
    return {
      'type': type.apiValue,
      'startDate': _formatDateOnly(startDate),
      'endDate': _formatDateOnly(endDate),
      'reason': reason.trim(),
    };
  }
}

Map<String, dynamic>? asLeaveRequestMap(dynamic value) {
  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return value.map((key, val) => MapEntry(key.toString(), val));
  }

  return null;
}

List<LeaveRequestItem> parseLeaveRequestList(dynamic response) {
  if (response is List) {
    return response
        .map(asLeaveRequestMap)
        .whereType<Map<String, dynamic>>()
        .map(LeaveRequestItem.fromJson)
        .toList(growable: false);
  }

  final root = asLeaveRequestMap(response);

  if (root == null) {
    return const [];
  }

  final data = root['data'];

  if (data is List) {
    return data
        .map(asLeaveRequestMap)
        .whereType<Map<String, dynamic>>()
        .map(LeaveRequestItem.fromJson)
        .toList(growable: false);
  }

  final dataMap = asLeaveRequestMap(data);

  if (dataMap != null) {
    final possibleLists = [
      dataMap['data'],
      dataMap['items'],
      dataMap['rows'],
      dataMap['results'],
      dataMap['leaveRequests'],
    ];

    for (final item in possibleLists) {
      if (item is List) {
        return item
            .map(asLeaveRequestMap)
            .whereType<Map<String, dynamic>>()
            .map(LeaveRequestItem.fromJson)
            .toList(growable: false);
      }
    }
  }

  return const [];
}

LeaveRequestItem parseLeaveRequestDetail(dynamic response) {
  final root = asLeaveRequestMap(response);

  final dynamic data = root != null
      ? root['data'] ?? root['result'] ?? root
      : response;

  final map = asLeaveRequestMap(data) ?? <String, dynamic>{};

  return LeaveRequestItem.fromJson(map);
}

DateTime? _parseDate(dynamic value) {
  if (value == null) {
    return null;
  }

  final rawValue = value.toString().trim();

  if (rawValue.isEmpty || rawValue == 'null') {
    return null;
  }

  return DateTime.tryParse(rawValue);
}

String? _parseNullableString(dynamic value) {
  if (value == null) {
    return null;
  }

  final rawValue = value.toString().trim();

  if (rawValue.isEmpty || rawValue == 'null') {
    return null;
  }

  return rawValue;
}

String _formatDateOnly(DateTime value) {
  final year = value.year.toString().padLeft(4, '0');
  final month = value.month.toString().padLeft(2, '0');
  final day = value.day.toString().padLeft(2, '0');

  return '$year-$month-$day';
}
