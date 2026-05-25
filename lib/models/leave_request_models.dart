enum LeaveRequestType {
  cuti,
  sakit,
}

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
    switch ((value ?? '').toUpperCase()) {
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
    final startDate = DateTime.tryParse((json['startDate'] ?? '').toString());
    final endDate = DateTime.tryParse((json['endDate'] ?? '').toString());

    return LeaveRequestItem(
      id: (json['id'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      type: LeaveRequestTypeValue.fromValue(json['type']?.toString()),
      startDate: startDate ?? DateTime.now(),
      endDate: endDate ?? DateTime.now(),
      reason: (json['reason'] ?? '').toString(),
      attachment: json['attachment']?.toString(),
      status: (json['status'] ?? 'PENDING').toString(),
      createdAt: DateTime.tryParse((json['created_at'] ?? '').toString()),
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
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'reason': reason,
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

  if (data is Map) {
    final innerData = data['data'];
    if (innerData is List) {
      return innerData
          .map(asLeaveRequestMap)
          .whereType<Map<String, dynamic>>()
          .map(LeaveRequestItem.fromJson)
          .toList(growable: false);
    }
  }

  return const [];
}

LeaveRequestItem parseLeaveRequestDetail(dynamic response) {
  final root = asLeaveRequestMap(response);
  final data = root != null ? root['data'] : response;

  final map = asLeaveRequestMap(data) ?? <String, dynamic>{};
  return LeaveRequestItem.fromJson(map);
}
